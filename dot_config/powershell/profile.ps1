# Add . ~/.config/powershell/profile.ps1 to $PROFILE

Invoke-Expression (& { (zoxide init powershell | Out-String) })
Set-Alias -Name cl -Value claude
Set-Alias -Name lg -Value lazygit
Set-Alias -Name wt -Value wezterm
Set-Alias -Name cm -Value chezmoi
