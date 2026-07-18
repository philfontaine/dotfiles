---
name: worktree
description: Switch into a reusable worktree and bring it up to the current HEAD on a new branch
argument-hint: "worktree-name branch-name"
disable-model-invocation: true
---

Note: git should work fine from any subdirectory. Do NOT use `cd` nor `git -C`.

This skill maintains a small pool of reusable worktrees (e.g. `wt1`, `wt2`). Worktrees are never
removed between uses, so any expensive one-time setup (submodules, `node_modules`, build output)
survives across invocations — each run just repoints the chosen worktree to a fresh branch at HEAD.

`$ARGUMENTS` is `worktree-name branch-name`. If either is missing, stop and ask for both.

0. **If currently in plan mode, stop immediately** — do not run any of the steps below. Tell the user
   to switch to auto mode first, then re-run this skill.

1. **Create the branch at current HEAD** (from the main session, before switching):
   `git branch <branch-name>`. Only ever create — never `--force` or reset an existing branch. If a
   branch with that name already exists, stop and warn the user (they can pick a different name or
   delete the old branch themselves).

2. **Resolve the worktree path**: `WT="$(git rev-parse --show-toplevel)/.claude/worktrees/<worktree-name>"`.
   Check `git worktree list`:
   - If `$WT` is not listed, this is first-time setup: run `git worktree add "$WT" <branch-name>`.
     Tell the user it's new and will need whatever build/package steps this repo requires.
   - If it is already listed, do nothing here — reuse it as-is.

3. **Enter the worktree**: call `EnterWorktree` with `path` set to `$WT` (not `name` — `name` would
   create a new auto-branched worktree instead of reusing this one).

4. **Check for uncommitted changes**: run `git status --porcelain` inside the worktree.
   - If it reports anything (tracked or untracked), **stop** and show the full `git status` output.
     Do not discard anything — let the user decide.
   - If clean, continue.

5. **Bring the worktree up to HEAD**: `git checkout <branch-name>`. This updates tracked files to
   match the new branch while leaving ignored build artifacts untouched.

6. **Sync submodules**: `git submodule update --init --recursive`.

7. **Report** the worktree path, the branch now checked out, and remind the user to run any
   build/package steps if this was a first-time setup.
