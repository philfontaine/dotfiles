---
name: git-diff
description: Load current git changes as context, then perform a task
---

First, run these commands to gather the current git state:
1. `git diff --cached` — staged changes
2. `git diff` — unstaged changes
3. `git status --short` — summary of changed files

Then perform the following task: $ARGUMENTS
