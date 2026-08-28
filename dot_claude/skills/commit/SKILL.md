---
name: commit
description: Commit session-related changes
allowed-tools: Bash(git status:*), Bash(git add:*), Bash(git commit:*)
disable-model-invocation: true
---

Only commit the files related to this conversation session. Use multiple atomic commits if some changes are unrelated. Inform the user if the working tree still has pending changes remaining.
