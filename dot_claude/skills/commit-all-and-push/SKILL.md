---
name: commit-all-and-push
description: Commit all changes and push to the remote branch
allowed-tools: Bash(git status:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*)
---

Note: git should work fine from any subdirectory. Do NOT use `cd` nor `git -C`.

1. Make multiple atomic commits if changes seem unrelated.
2. Push to the current remote tracking branch.
