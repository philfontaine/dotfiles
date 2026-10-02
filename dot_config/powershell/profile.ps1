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
Set-Alias -Name sg -Value SourceGit

# z excludes the current directory from its matches, so it can never resolve to where we already are
function zcl {
    if ((zoxide query -- @args 2>$null) -ne $PWD.Path) {
        $global:LASTEXITCODE = 0
        try { z @args } catch { Write-Error $_; return }
        if ($LASTEXITCODE -ne 0) { return }
    }
    claude
}
