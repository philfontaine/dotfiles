---
name: review-worktree
description: Review a branch in an isolated worktree so the main worktree stays free for other work
argument-hint: "[PR number or branch, defaults to the current branch]"
disable-model-invocation: true
---

The review runs in a separate worktree so the user can switch branches in main and keep working meanwhile.

1. **Pin the target now**, since HEAD in main may move during the review:
   - No argument: the current branch and `git rev-parse HEAD`. If `git status` shows uncommitted changes, tell the
     user they won't be reviewed.
   - A branch: that branch and its SHA.
   - A PR number: `gh pr view <n> --json headRefName,headRefOid`, then `git fetch origin <headRefName>`.

2. **Spawn the review** as a subagent with `isolation: "worktree"` that:
   - Checks out the pinned SHA on a detached HEAD: `git checkout --detach <sha>`. Checking out the branch itself
     fails if it's already checked out in another worktree.
   - Reviews it with the `review` skill, targeting the branch (or PR number). If it builds or tests, it follows
     `dotnet-shadow-build`. Expect a slow first build: the worktree has no `node_modules` or restored packages.
   - Reports findings with `file:line` references, in the Correctness and Design sections of the `review` skill.

   Tell the user they're free to switch branches while it runs.

3. **Present the findings** along with the reviewed branch and SHA. Then stop. Never switch branches.

When the user later asks to apply fixes, first check that main is on the reviewed branch. If it isn't, stop and say so.
If the branch moved past the reviewed SHA, show `git log <sha>..HEAD` and recheck the affected findings.
