param (
    [string]$message
)

# Define ANSI escape codes for colors
$Reset = [char]27 + '[0m'
$Red = [char]27 + '[31m'
$Green = [char]27 + '[32m'
$Yellow = [char]27 + '[33m'

function CheckMessage($message)
{
    if (!($message))
    {
        throw "Missing commit message."
    }
}

function ExecuteGitCommand($command)
{
    Invoke-Expression $command
    if ($LastExitCode -ne 0)
    {
        throw "Error executing '$command' ($LastExitCode)."
    }
}

CheckMessage $message

ExecuteGitCommand "git add ."
ExecuteGitCommand "git commit -m '$message'"
ExecuteGitCommand "git push"

Write-Host "${Green}Done${Reset}"
 