---
name: review
description: Review a change for correctness bugs and for design, as two parallel subagents. Use when the user asks for a review, a code review, or a review subagent of the current diff, a branch, or a PR.
argument-hint: "[PR number, branch, or path, defaults to the current diff] [mine|theirs]"
---

A review has two passes: correctness and design. They run as separate subagents because in a single pass, concrete
bugs crowd out design judgment.

1. **Pin the target** from `$ARGUMENTS` and pass it unchanged to both passes:
   - Nothing: the uncommitted changes, or the current branch against its merge base with the default branch if the
     tree is clean.
   - A PR number, a branch, or a path: that.

2. **Find whose code it is.** `$ARGUMENTS` can say `mine` or `theirs`. Otherwise:
   - a. Uncommitted changes or a path: mine.
   - b. A branch: mine only if every commit since the merge base has the user's `git config user.email` as author.
   - c. A PR: mine only if the user (`gh api user --jq .login`) is the PR author and the author of every commit
     (`gh pr view --json author,commits`).

   When it's theirs, give both passes the [Someone else's code](#someone-elses-code) section below, verbatim.

3. **Spawn both passes in one message**, so they run in parallel:
   - a. **Correctness:** a subagent that reviews the target with the `code-review` skill, then reports each finding
     in the [Finding format](#finding-format) section below, given verbatim, with IDs `C1`, `C2`, …
   - b. **Design:** a subagent given the target and the [Design pass](#design-pass) and
     [Finding format](#finding-format) sections below, verbatim, with IDs `D1`, `D2`, …

   If you can't spawn subagents because you are one, run the passes yourself, correctness first, and re-read the
   Design pass and Finding format sections before starting it, along with Someone else's code when it applies.

4. **Present one report:**
   - a. A first line naming the target and whose code it is, such as `Reviewing PR 123 (theirs)`, so the user can
     rerun with `mine` or `theirs` if the detection got it wrong.
   - b. A summary table, `ID | Problem | Fix size | Verdict`, one row per finding, so the user can pick
     findings before reading the details.
   - c. A Correctness section, then a Design section, each finding in full in the Finding format. Keep every design
     finding, even without a failure scenario.

   Then stop: apply nothing until the user picks findings.

## Someone else's code

The user didn't write this code, so their personal preferences don't apply to it: the instructions in
`~/.claude/CLAUDE.md` and the user-level skills such as `csharp-style`. Don't report code for not following them,
for example a comment the user wouldn't have written or a name they would have picked differently. The author is
expected to follow the project's own conventions only: its `CLAUDE.md`, `.editorconfig` and linter config.

## Finding format

A finding exists to help the user decide whether to fix it. Show the problem and the fix in code rather than
describing them, so the user can see what goes wrong and how big the fix is at a glance.

````markdown
### <ID> · <the problem in a few words>. Fix: <fix size>

**Problem** (`file:line`): <a concrete example of what goes wrong>
```<language>
<the offending lines>
```

**Fix**
```diff
<the fix against the real code>
```

**Verdict**: <fix now | later | skip>. <the reason, in one sentence>
````

1. **Problem** is concrete: the offending lines, plus a scenario that shows the failure, such as an input or a
   sequence of calls and the wrong result it produces. For a design finding, show the code that makes the next change
   painful, such as the branch the next similar feature would have to copy.
2. **Fix** is a `diff` against the real code. When the fix is big, show only enough to judge its size: the new
   signature or type, one call site before and after, and a list of the other files it touches.
3. **Fix size** is one of `one-liner`, `local` (one function or file), `multi-file` or `refactor`.
4. **Verdict** weighs the risk or payoff against the fix size: *fix now*, *later* as a follow-up, or *skip*. For a
   design finding, *now* means it's cheaper to do before this change merges.

## Design pass

Review the target as a feature, not as a set of changed lines. The question is whether this is the shape the code
should have for the next year of changes, and what refactor would get it there. Bugs are covered by another pass.

**Read beyond the diff.** Before judging, read the callers of the changed code, the sibling features that solve
similar problems, and the project's `CONTEXT.md`, `GLOSSARY.md` and ADRs when they exist. Most design problems are
only visible against the rest of the codebase. Don't build or run tests.

Look for:

1. **Fit:** the feature bolts onto an abstraction instead of extending it, or ignores one that already exists.
2. **Duplication:** logic that already exists elsewhere and could be reused.
3. **Consistency:** a similar feature implemented a different way. Find out whether the difference is deliberate, from
   the code, comments and `git log`. If it is, say why and move on. If not, propose aligning both on the better of
   the two approaches, even when that means changing the existing feature rather than the new one.
4. **Preparatory refactor:** a refactor of the existing code that would have made this change small and obvious.
5. **Ownership:** logic in the wrong layer or class, or new coupling between modules that didn't know each other.
6. **Special cases:** new flags, boolean parameters, `if (kind == …)` branches or type checks that a polymorphic or
   data-driven shape would absorb.
7. **Naming:** names that don't match the domain language, or one concept under two names.
8. **Change cost:** what the next similar feature would have to touch, and whether the code is testable without
   heavy setup.

Don't report bugs, formatting, linter-level issues, or preferences with no maintenance payoff.

Report **at most 3 findings**, the ones with the biggest long-term payoff. "No design concerns" is a valid result.
Report each finding in the Finding format, with a Fix concrete enough to start on.
