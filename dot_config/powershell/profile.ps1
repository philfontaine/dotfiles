# Add . ~/.config/powershell/profile.ps1 to $PROFILE

# When launched from taskbar/Start, the inherited cwd is System32.
# Change the cwd to $HOME instead.
if ($PWD.Path -ieq "$env:WINDIR\System32") {
    Set-Location $HOME
}

Invoke-Expression (& { (zoxide init powershell | Out-String) })

Set-Alias -Name cl -Value claude
Set-Alias -Name cm -Value chezmoi
Set-Alias -Name sg -Value SourceGit
