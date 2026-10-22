---
name: stage-review
description: Stage the changed files that don't need the user's review and unstage the ones that do
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git restore --staged:*)
disable-model-invocation: true
---

Sort the uncommitted files for the user to review: staged means no review needed, unstaged means review needed.
Staging is a review filter here, not a commit in preparation.

1. Stage the files that don't need review: mechanical changes, renames, simple refactors, etc.
2. Unstage the files that need review: logic or behavior changes, changed conditions, values or defaults, signature
   or API changes, error handling, config, dependency versions, schema or migrations, security or permissions, test
   assertions, new files (other than moves), deleted code. A file needs review if any of its changes does. In doubt,
   leave it unstaged.
3. Give a short summary of what was staged, then list each unstaged file with a few words on what to review in it.
