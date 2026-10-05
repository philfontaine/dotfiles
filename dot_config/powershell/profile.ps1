# Add . ~/.config/powershell/profile.ps1 to $PROFILE

# When launched from taskbar/Start, the inherited cwd is System32.
# Change the cwd to $HOME instead.
if ($PWD.Path -ieq "$env:WINDIR\System32") {
    Set-Location $HOME
}

Invoke-Expression (& { (zoxide init powershell | Out-String) })

Set-Alias -Name cl -Value claude
Set-Alias -Name cm -Value chezmoi
Set-Alias -Name ex -Value explorer
Set-Alias -Name nv -Value nvim -Force
Set-Alias -Name sg -Value SourceGit

# z excludes the current directory from its matches, so it can never resolve to where we already are
function Enter-ZLocation {
    if ((zoxide query -- @args 2>$null) -eq $PWD.Path) { return $true }
    $global:LASTEXITCODE = 0
    try { z @args } catch { Write-Error $_; return $false }
    $LASTEXITCODE -eq 0
}

function zcl { if (Enter-ZLocation @args) { claude } }
function znv { if (Enter-ZLocation @args) { nvim . } }

function New-Tab([string] $Title, [string] $Script) {
    wt -w 0 new-tab --title $Title --suppressApplicationTitle pwsh -NoLogo -NoExit -File $Script
}

function Split-Pane([string] $Title, [string] $Script) {
    wt -w 0 split-pane -V --title $Title --suppressApplicationTitle pwsh -NoLogo -NoExit -File $Script
}
