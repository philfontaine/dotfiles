param (
    [string]$version
)

# Define ANSI escape codes for colors
$Reset = [char]27 + '[0m'
$Red = [char]27 + '[31m'
$Green = [char]27 + '[32m'
$Yellow = [char]27 + '[33m'

function ExecuteGitCommand($command)
{
    Invoke-Expression $command
    if ($LastExitCode -ne 0)
    {
        throw "Error executing '$command' ($LastExitCode)."
    }
}

Write-Host "Releasing v$version..."

ExecuteGitCommand "git add ."
ExecuteGitCommand "git commit -m 'release: v$version'"
ExecuteGitCommand "git push"
ExecuteGitCommand "git tag 'v$version'"
ExecuteGitCommand "git push origin 'v$version'"

Write-Host "${Green}Released v$version${Reset}"
 