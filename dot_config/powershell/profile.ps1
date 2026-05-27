# Add . ~/.config/powershell/profile.ps1 to $PROFILE

Invoke-Expression (& { (zoxide init powershell | Out-String) })

Set-Alias -Name cl -Value claude
Set-Alias -Name lg -Value lazygit
Set-Alias -Name wt -Value wezterm
Set-Alias -Name cm -Value chezmoi

# Claude Code OpenRouter
function clor {
    $claudeEnv = [System.Environment]::GetEnvironmentVariables()
    $claudeEnv["ANTHROPIC_BASE_URL"] = "https://openrouter.ai/api"
    $claudeEnv["ANTHROPIC_AUTH_TOKEN"] = $claudeEnv["OPENROUTER_API_KEY"]
    $claudeEnv["ANTHROPIC_API_KEY"] = ""
    $claudeEnv["ANTHROPIC_DEFAULT_OPUS_MODEL"] = "deepseek/deepseek-v4-pro"
    $claudeEnv["ANTHROPIC_DEFAULT_SONNET_MODEL"] = "deepseek/deepseek-v4-pro"
    $claudeEnv["ANTHROPIC_DEFAULT_HAIKU_MODEL"] = "deepseek/deepseek-v4-flash"
    Start-Process -FilePath claude -Environment $claudeEnv -NoNewWindow -Wait -ArgumentList $args
}
