# PreToolUse (Bash) guard: block a `find` that targets a OneDrive folder.
# Recursing into OneDrive forces Files On-Demand to download every file.
$ErrorActionPreference = 'Stop'

try {
    $cmd = [string]([Console]::In.ReadToEnd() | ConvertFrom-Json).tool_input.command
} catch {
    exit 0   # unparseable input -> never block
}

$isFind    = $cmd -match '(?im)(?:^|[;&|(`])\s*find(?:\.exe)?\s'
$hitsOneDrive = $cmd -match '(?i)onedrive'
if (-not ($isFind -and $hitsOneDrive)) { exit 0 }

@{
    hookSpecificOutput = @{
        hookEventName            = 'PreToolUse'
        permissionDecision       = 'deny'
        permissionDecisionReason = "Blocked by OneDrive guard: this 'find' scans a OneDrive folder, which forces OneDrive to download every file on demand. Scope the search to the project directory, or use the Grep/Glob tools instead."
    }
} | ConvertTo-Json -Compress -Depth 5
