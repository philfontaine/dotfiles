#!/bin/bash

# Define ANSI escape codes for colors
Reset='\033[0m'
Red='\033[31m'
Green='\033[32m'
Yellow='\033[33m'

execute_git_command() {
    local command="$1"
    echo "Executing: $command"
    
    if ! eval "$command"; then
        echo -e "${Red}Error executing '$command' (exit code: $?)${Reset}" >&2
        exit 1
    fi
}

# Check if version parameter is provided
if [ -z "$1" ]; then
    echo -e "${Red}Missing version.${Reset}" >&2
    exit 1
fi

version="$1"

echo "Releasing v$version..."

execute_git_command "git add ."
execute_git_command "git commit -m 'release: v$version'"
execute_git_command "git push"
execute_git_command "git tag 'v$version'"
execute_git_command "git push origin 'v$version'"

echo -e "${Green}Released v$version${Reset}"
