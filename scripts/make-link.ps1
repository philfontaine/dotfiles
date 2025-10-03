param (
    [string]$target,
    [string]$link
)

New-Item -Path $link -ItemType SymbolicLink -Value $target
