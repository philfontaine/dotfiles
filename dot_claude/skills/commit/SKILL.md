---
name: commit
description: Commit session-related changes
allowed-tools: Bash(git status:*), Bash(git add:*), Bash(git commit:*)
disable-model-invocation: true
---

- Only commit the files related to this conversation session, including the changes the user made themselves that are part of the same work you were asked to continue.
- Use multiple atomic commits if some changes are unrelated.
- Inform the user if the working tree still has pending changes remaining.
