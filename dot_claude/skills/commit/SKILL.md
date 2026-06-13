---
name: commit
description: Commit session-related changes
---

Note: git should work fine from any subdirectory. Do NOT use `cd` nor `git -C`.

1. Review the files you have read or modified during this conversation session.
2. Stage only those specific files (do not use `git add .` or `git add -A`).
3. Make multiple atomic commits if the session changes seem unrelated.
4. Run `git status` and inform the user whether all working tree changes were committed, or if there are still unrelated pending changes remaining (unstaged, staged, or untracked files).
