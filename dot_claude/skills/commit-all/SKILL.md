---
name: commit-all
description: Commit all changes
allowed-tools: Bash(git status:*), Bash(git add:*), Bash(git commit:*)
disable-model-invocation: true
---

Note: git should work fine from any subdirectory. Do NOT use `cd` nor `git -C`.

1. Make multiple atomic commits if changes seem unrelated.
