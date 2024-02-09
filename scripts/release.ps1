param (
    [string]$version
)

# Define ANSI escape codes for colors
$Reset = [char]27 + '[0m'
$Red = [char]27 + '[31m'
$Green = [char]27 + '[32m'
$Yellow = [char]27 + '[33m'

function CheckVersion($version)
{
    if (!($version))
    {
        throw "Missing version. Please provide a version as an argument."
    }

    $semVerRegex = '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(\-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$'
    if (!($version -match $semVerRegex))
    {
        throw "Invalid version. Please provide a valid SemVer version."
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

Write-Host "Releasing v$version..."

CheckVersion $version

ExecuteGitCommand "git add ."
ExecuteGitCommand "git commit -m 'release: v$version'"
ExecuteGitCommand "git push"
ExecuteGitCommand "git tag 'v$version'"
ExecuteGitCommand "git push origin 'v$version'"

Write-Host "${Green}Released v$version${Reset}"
 