---
name: git-diff
description: Load current git changes as context, then perform a task
disable-model-invocation: true
---

First, run these commands to gather the current git state:

1. `git diff HEAD`
2. `git status --short` — summary of changed files

Then perform the following task: $ARGUMENTS
