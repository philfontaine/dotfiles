---
name: checkout
description: Check out a PR or a branch, bring it up to date with its remote and sync submodules
argument-hint: "PR number, PR URL or branch name"
allowed-tools: Bash(git status:*), Bash(git fetch:*), Bash(git switch:*), Bash(git merge --ff-only:*), Bash(git submodule:*), Bash(git log:*), Bash(git rev-parse:*), Bash(gh pr checkout:*), Bash(gh pr view:*)
disable-model-invocation: true
---

`$ARGUMENTS` is the target: a number, `#123` or a PR URL means a PR, anything else is a branch. If it's missing,
stop and ask for it. Strip a remote prefix from a branch (`origin/foo` means `foo`).

1. **Check the working tree**: `git status --porcelain`. If it reports anything, including submodules with new
   commits or modified content, stop, show it and ask whether to switch anyway. Changes that don't conflict carry
   over to the new branch, and `git submodule update` would detach a submodule from its local commits. Never stash,
   discard or force anything.

2. **Switch**:
   - A PR: `gh pr checkout <n>`. It handles forks, and fast-forwards the local branch if it already exists.
   - A branch: `git fetch origin`, then `git switch <branch>`, which creates a tracking branch if it only exists on
     `origin`. If the branch has an upstream, fast-forward it with `git merge --ff-only @{u}`.

   If the local branch diverged from its remote, or the branch is checked out in another worktree, stop and report.
   Never reset, force or create a branch with a different name to get around it.

3. **Sync submodules**: `git submodule sync --recursive`, then `git submodule update --init --recursive`. The sync
   picks up submodule URLs changed by the new branch. If a submodule was removed by the new branch, its directory
   stays behind as untracked files: mention it, don't delete it.

4. **Report** the branch, its short SHA and subject (`git log -1 --oneline`), its upstream, the PR title for a PR
   (`gh pr view <n> --json title`), and the submodules whose commit changed.
