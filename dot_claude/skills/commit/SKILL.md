---
name: commit
description: Commit session-related changes
allowed-tools: Bash(git status:*), Bash(git add:*), Bash(git commit:*)
disable-model-invocation: true
---

- Commit on the current branch, even `main`. Never create or switch branches.
- If the current branch's name has nothing to do with the work being committed, it is likely a mistake: say so, name
  the branch, and ask for confirmation before committing. A generic branch such as `main` or `develop` never counts.
- Only commit the files related to this conversation session, including the changes the user made themselves that are part of the same work you were asked to continue.
- Use multiple atomic commits if some changes are unrelated.
- Inform the user if the working tree still has pending changes remaining.
