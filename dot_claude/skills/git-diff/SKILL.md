---
name: git-diff
description: Load current git changes as context, then perform a task
argument-hint: "What's the task to perform?"
disable-model-invocation: true
---

First, run these commands to gather the current git state:

## New Files

1. `git ls-files --others --exclude-standard`
2. Read all listed files

## Tracked Files

1. `git diff HEAD`

Then perform the following task: $ARGUMENTS
