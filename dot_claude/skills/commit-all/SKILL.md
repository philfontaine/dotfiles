---
name: commit-all
description: Commit all changes
allowed-tools: Bash(git status:*), Bash(git add:*), Bash(git commit:*)
disable-model-invocation: true
---

- Commit all changes in the working tree.
- Commit on the current branch, even `main`. Never create or switch branches.
- If the current branch's name has nothing to do with the work being committed, it is likely a mistake: say so, name
  the branch, and ask for confirmation before committing. A generic branch such as `main` or `develop` never counts.
- Use multiple atomic commits if changes seem unrelated.
