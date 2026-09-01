param (
    [string]$installPath = 'C:\Program Files\SourceGit',
    [switch]$force
)

$ErrorActionPreference = 'Stop'

# Define ANSI escape codes for colors
$Reset = [char]27 + '[0m'
$Red = [char]27 + '[31m'
$Green = [char]27 + '[32m'
$Yellow = [char]27 + '[33m'
$Cyan = [char]27 + '[36m'

function WriteStep($message)
{
    Write-Host "${Cyan}==>${Reset} $message"
}

# A version built from a 2-part tag ("2026.19") reports -1 for the missing
# parts, so pad everything to 4 parts before comparing.
function NormalizeVersion([string]$rawVersion)
{
    $parsed = [version]($rawVersion.TrimStart('v').Split('+')[0])
    return [version]::new(
        $parsed.Major,
        [Math]::Max($parsed.Minor, 0),
        [Math]::Max($parsed.Build, 0),
        [Math]::Max($parsed.Revision, 0))
}

# Step 1: read the version of the installed executable
WriteStep "Reading installed version from $installPath..."
$executablePath = Join-Path $installPath 'SourceGit.exe'
if (Test-Path $executablePath)
{
    $installedVersion = NormalizeVersion (Get-Item $executablePath).VersionInfo.FileVersion
    Write-Host "    Installed: $installedVersion"
}
else
{
    $installedVersion = [version]'0.0.0.0'
    Write-Host "    ${Yellow}Not installed${Reset} (no SourceGit.exe found)"
}

# Step 2: ask the GitHub API for the latest published release
WriteStep 'Checking the latest release on GitHub...'
$release = Invoke-RestMethod `
    -Uri 'https://api.github.com/repos/sourcegit-scm/sourcegit/releases/latest' `
    -Headers @{ 'User-Agent' = 'update-sourcegit.ps1' }
$latestVersion = NormalizeVersion $release.tag_name
Write-Host "    Latest: $latestVersion ($($release.tag_name))"

# Step 3: compare both versions and stop early when already up to date
WriteStep 'Comparing versions...'
if ($latestVersion -le $installedVersion -and !$force)
{
    Write-Host "    ${Green}Already up to date.${Reset}"
    return
}
if ($latestVersion -le $installedVersion)
{
    Write-Host "    ${Yellow}Already up to date, reinstalling anyway (-force).${Reset}"
}
else
{
    Write-Host "    ${Yellow}Update available: $installedVersion -> $latestVersion${Reset}"
}

# Step 4: fail before downloading if the install folder is not writable
# (C:\Program Files needs an elevated shell)
WriteStep 'Checking write access to the install folder...'
$writeTestPath = if (Test-Path $installPath) { $installPath } else { Split-Path -Parent $installPath }
try
{
    $probePath = Join-Path $writeTestPath ".write-test-$(Get-Random)"
    New-Item -Path $probePath -ItemType File | Out-Null
    Remove-Item -Path $probePath -Force
    Write-Host '    Writable'
}
catch
{
    throw "$writeTestPath is not writable. Run this script from an elevated shell."
}

# Step 5: locate the Windows x64 archive in the release assets
WriteStep 'Locating the win-x64 asset...'
$asset = $release.assets | Where-Object { $_.name -like '*win-x64.zip' } | Select-Object -First 1
if (!$asset)
{
    throw 'No win-x64 zip found in the latest release.'
}
Write-Host "    $($asset.name) ($([Math]::Round($asset.size / 1MB, 1)) MB)"

# Everything below unpacks into a scratch folder that is always cleaned up
$workPath = Join-Path ([IO.Path]::GetTempPath()) "sourcegit-update-$(Get-Random)"
# A freshly copied SourceGit.exe stays locked for a moment (virus scanning),
# so deleting the scratch folder needs a few attempts
function RemoveWorkFolder
{
    foreach ($attempt in 1..5)
    {
        try
        {
            Remove-Item -Path $workPath -Recurse -Force -ErrorAction Stop
            return $true
        }
        catch
        {
            Start-Sleep -Seconds 2
        }
    }
    return !(Test-Path $workPath)
}

$extractPath = Join-Path $workPath 'extracted'
$backupPath = Join-Path $workPath 'backup'
New-Item -Path $workPath -ItemType Directory | Out-Null

try
{
    # Step 6: download the archive
    WriteStep 'Downloading...'
    $archivePath = Join-Path $workPath $asset.name
    $progressPreferenceBackup = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $archivePath
    $ProgressPreference = $progressPreferenceBackup
    Write-Host "    $archivePath"

    # Step 7: unzip it
    WriteStep 'Extracting...'
    Expand-Archive -Path $archivePath -DestinationPath $extractPath
    # Some releases nest everything in a single folder, others do not
    $extractedRoot = $extractPath
    $extractedItems = @(Get-ChildItem -Path $extractPath)
    if ($extractedItems.Count -eq 1 -and $extractedItems[0].PSIsContainer)
    {
        $extractedRoot = $extractedItems[0].FullName
    }
    if (!(Test-Path (Join-Path $extractedRoot 'SourceGit.exe')))
    {
        throw "The archive does not contain SourceGit.exe."
    }
    Write-Host "    $(@(Get-ChildItem -Path $extractedRoot -Recurse -File).Count) file(s) extracted"

    # Step 8: close SourceGit so its files are not locked
    WriteStep 'Checking for a running SourceGit...'
    $runningProcesses = @(Get-Process -Name 'SourceGit' -ErrorAction SilentlyContinue |
        Where-Object { $_.Path -eq $executablePath })
    if ($runningProcesses)
    {
        Write-Host "    ${Yellow}Stopping $($runningProcesses.Count) running instance(s)...${Reset}"
        $runningProcesses | Stop-Process -Force
        $runningProcesses | Wait-Process -Timeout 15
    }
    else
    {
        Write-Host '    Not running'
    }

    # Step 9: replace the contents of the install folder, keeping a backup so a
    # failed install can be rolled back. The folder itself is never moved or
    # deleted: recreating it under C:\Program Files needs more rights than
    # writing inside it does.
    WriteStep "Installing to $installPath..."
    if (Test-Path $installPath)
    {
        Copy-Item -Path $installPath -Destination $backupPath -Recurse
        Write-Host "    Previous version backed up to $backupPath"
    }
    else
    {
        New-Item -Path $installPath -ItemType Directory | Out-Null
    }
    try
    {
        Get-ChildItem -Path $installPath -Force | Remove-Item -Recurse -Force
        Copy-Item -Path (Join-Path $extractedRoot '*') -Destination $installPath -Recurse -Force
    }
    catch
    {
        if (Test-Path $backupPath)
        {
            Write-Host "    ${Red}Install failed, restoring the previous version...${Reset}"
            Get-ChildItem -Path $installPath -Force | Remove-Item -Recurse -Force
            Copy-Item -Path (Join-Path $backupPath '*') -Destination $installPath -Recurse -Force
        }
        throw
    }
    Write-Host '    Done'

    # Step 10: confirm what ended up on disk
    WriteStep 'Verifying...'
    $newVersion = NormalizeVersion (Get-Item $executablePath).VersionInfo.FileVersion
    Write-Host "${Green}SourceGit updated to $newVersion${Reset}"

    # Step 11: the backup is only discarded once the new version is in place;
    # a failed run leaves it behind on purpose
    WriteStep 'Cleaning up...'
    if (RemoveWorkFolder)
    {
        Write-Host '    Removed temporary files'
    }
    else
    {
        Write-Host "    ${Yellow}Could not remove $workPath, delete it manually${Reset}"
    }
}
catch
{
    Write-Host "${Red}Update failed. Files from this run were kept in $workPath${Reset}"
    throw
}
