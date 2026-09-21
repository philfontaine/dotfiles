param (
    [string]$tool,
    [switch]$clean
)

$ErrorActionPreference = 'Stop'

# Define ANSI escape codes for colors
$Reset = [char]27 + '[0m'
$Green = [char]27 + '[32m'
$Yellow = [char]27 + '[33m'
$Cyan = [char]27 + '[36m'

function WriteStep($message)
{
    Write-Host "${Cyan}==>${Reset} $message"
}

$repoPath = Split-Path $PSScriptRoot -Parent
$toolsPath = Join-Path $repoPath 'dot_claude/tools'
$outputPath = Join-Path $repoPath 'dot_claude/bin'
$artifactsPath = Join-Path $env:LOCALAPPDATA 'claude-tools-build'

# Publishes a dotnet project as a self-contained Native AOT binary. $project is
# relative to tools/ and can be a single .cs file or a .csproj.
function PublishDotnetAot($toolName, $project)
{
    # The Native AOT linker locates the MSVC toolchain by calling vswhere
    # without a path, so it only works when the VS installer folder is on PATH
    $installerPath = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer'
    if (!(Test-Path (Join-Path $installerPath 'vswhere.exe')))
    {
        throw "vswhere.exe not found in $installerPath. Native AOT needs the Visual Studio C++ build tools."
    }
    if (($env:PATH -split ';') -notcontains $installerPath)
    {
        $env:PATH = "$installerPath;$env:PATH"
    }

    $projectPath = Join-Path $toolsPath $project
    if (!(Test-Path $projectPath))
    {
        throw "No project at $projectPath."
    }

    # --artifacts-path keeps bin/obj out of the repo, and -o puts the binary in
    # dot_claude/bin. Both have to be explicit: under an agent shell
    # ~/.claude/ShadowBuild.props otherwise redirects them into the shadow build
    # tree, and an explicit flag is what overrides that props file.
    $toolArtifactsPath = Join-Path $artifactsPath $toolName
    if ($clean -and (Test-Path $toolArtifactsPath))
    {
        Remove-Item -Path $toolArtifactsPath -Recurse -Force
    }

    dotnet publish $projectPath `
        --configuration Release `
        --output $outputPath `
        --artifacts-path $toolArtifactsPath
    if ($LASTEXITCODE -ne 0)
    {
        throw "dotnet publish exited with $LASTEXITCODE."
    }
}

# Every tool is listed here with the command that builds it. Nothing is inferred
# from the folder layout, so a tool is free to be a single .cs file, a multi
# project dotnet solution, or something written in another language.
$builders = [ordered]@{
    'status-line' = { PublishDotnetAot 'status-line' 'status-line/status-line.cs' }
    'hook-shadow-build' = { PublishDotnetAot 'hook-shadow-build' 'hook-shadow-build/hook-shadow-build.cs' }
    'hook-block-onedrive-find' = { PublishDotnetAot 'hook-block-onedrive-find' 'hook-block-onedrive-find/hook-block-onedrive-find.cs' }
    'hook-toast' = { PublishDotnetAot 'hook-toast' 'hook-toast/hook-toast.cs' }
}

# Step 1: pick the tools to build
WriteStep 'Collecting tools...'
$toolNames = @($builders.Keys)
if ($tool)
{
    if (!$builders.Contains($tool))
    {
        throw "No tool named '$tool'. Known tools: $($toolNames -join ', ')."
    }
    $toolNames = @($tool)
}
Write-Host "    $($toolNames.Count) tool(s):"
foreach ($toolName in $toolNames)
{
    Write-Host "      $toolName"
}

New-Item -Path $outputPath -ItemType Directory -Force | Out-Null

# Step 2: run each builder, keeping going so one broken tool does not hide the
# state of the others
$failures = @()
foreach ($toolName in $toolNames)
{
    WriteStep "Building $toolName..."
    try
    {
        & $builders[$toolName]
    }
    catch
    {
        $failures += $toolName
        Write-Host "    ${Yellow}Failed: $($_.Exception.Message)${Reset}"
        continue
    }

    $binaryPath = Join-Path $outputPath "$toolName.exe"
    if (Test-Path $binaryPath)
    {
        $binary = Get-Item $binaryPath
        Write-Host "    $($binary.FullName) ($([Math]::Round($binary.Length / 1MB, 1)) MB)"
    }
    else
    {
        Write-Host "    ${Yellow}Built, but no $toolName.exe in $outputPath${Reset}"
    }
}

if ($failures)
{
    throw "Failed to build: $($failures -join ', ')"
}

# Step 3: copy the binaries to ~/.claude/bin. Scoped to that one folder so a
# build never applies unrelated config that happens to be pending elsewhere in
# the repo, and so an edit left in ~/.claude is only ever overwritten there.
#
# --force because chezmoi otherwise stops to ask about any binary that changed
# since it last wrote one, which hangs a non-interactive build. These are build
# output, so the freshly published binary is always the one that should win.
$binTargetPath = Join-Path $HOME '.claude/bin'
WriteStep "Applying to $binTargetPath..."
chezmoi apply --force $binTargetPath
if ($LASTEXITCODE -ne 0)
{
    throw "chezmoi apply exited with $LASTEXITCODE."
}
Write-Host '    Done'

Write-Host "${Green}Built and applied $($toolNames.Count) tool(s)${Reset}"
