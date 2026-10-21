---
name: review
description: Review a change for correctness bugs and for design, as two parallel subagents. Use when the user asks for a review, a code review, or a review subagent of the current diff, a branch, or a PR.
argument-hint: "[PR number, branch, or path, defaults to the current diff]"
---

A review has two passes: correctness and design. They run as separate subagents because in a single pass, concrete
bugs crowd out design judgment.

1. **Pin the target** from `$ARGUMENTS` and pass it unchanged to both passes:
   - Nothing: the uncommitted changes, or the current branch against its merge base with the default branch if the
     tree is clean.
   - A PR number, a branch, or a path: that.

2. **Spawn both passes in one message**, so they run in parallel:
   - a. **Correctness:** a subagent that reviews the target with the `code-review` skill and reports findings with
     `file:line` references.
   - b. **Design:** a subagent given the target and the [Design pass](#design-pass) section below, verbatim.

   If you can't spawn subagents because you are one, run the passes yourself, correctness first, and re-read the
   Design pass section before starting it.

3. **Present one report** with a Correctness section (`C1`, `C2`, …) and a Design section (`D1`, `D2`, …). Keep every
   design finding, even without a failure scenario. Then stop: apply nothing until the user picks findings.

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
Each finding has:

- **Where:** `file:line` references.
- **Current shape:** what the code does now, in a sentence or two.
- **Proposed shape:** the refactor, concrete enough to start on.
- **Payoff:** what gets easier or safer afterwards.
- **Cost:** rough size of the refactor and what it risks.
- **When:** *now*, if it's cheaper before this change merges, or *later*, as a follow-up.
