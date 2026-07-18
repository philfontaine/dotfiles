---
name: implement
description: Plan, review, implement, verify, and re-review a feature end-to-end with an independent sub-agent reviewer at each stage. User-invoked; must run in plan mode.
argument-hint: "What will be implemented?"
disable-model-invocation: true
---

Run a disciplined plan → review → implement → verify → review loop for the requested feature.

## 0. Preconditions

- This skill MUST run in plan mode. If you are not currently in plan mode, STOP and ask the user to switch to plan mode (Shift+Tab), then re-invoke this skill.
- Determine what to implement from the skill argument and the conversation. If the task is unclear or ambiguous, ask the user before continuing.

## 1. Plan

- Plan the feature as you normally would in plan mode: explore the codebase, design the approach, and write the plan file.
- If the design has open questions or competing branches, use the `/grill-me` skill to resolve them with the user.

## 2. Plan review loop (max 3 rounds)

This loop has its own independent budget of 3 rounds, separate from the implementation review loop in step 6.

- Spawn a **general-purpose** sub-agent using the **sonnet** model to review the plan. Give it: the task being implemented, the full plan (or the plan file path and its contents), and key constraints. Instruct it to be adversarial and to return findings each tagged **blocking** or **non-blocking**, checking: correctness, completeness vs. the task, scope (over/under-engineering), and risks.
- Resolve every **blocking** finding by updating the plan. Note non-blocking findings; they do not block.
- Repeat using the same sub-agent until the reviewer reports no unresolved blocking findings, or 3 rounds have passed.
- If blocking findings remain unresolved after 3 rounds (you and the reviewer genuinely disagree), STOP and present the specific unresolved points to the user to decide.

## 3. Approval

- Output the final plan and request approval as you normally would (ExitPlanMode).

## 4. Implement

- Once approved, first confirm the worktree is clean; if not, STOP and ask the user to clean it. Then implement the plan as you normally would.
- Do NOT commit anything at this point.

## 5. Verify

- Run the project's checks and fix any failures: build, test, and lint (e.g. `dotnet build --no-restore` / `dotnet test`, or `pnpm lint` / `pnpm tsc`), or invoke the `/verify` skill. Run this after implementing and again after each review-driven change.
- If no build/test/lint tooling applies to this change (e.g. docs-only, config-only, or no verify skill/commands exist for this project), state that explicitly and skip this step rather than treating it as a failure or looping on it.

## 6. Implementation review loop (max 3 rounds)

This loop has its own independent budget of 3 rounds, separate from the plan review loop in step 2.

- Before reviewing, use `git add -A` to stage your changes.
- Spawn a **general-purpose** sub-agent using the **sonnet** model to review your work. Give it: the task, the approved plan, and the staged diff (`git diff --staged`, uncommitted, against the pre-implementation state — this is why nothing is committed during steps 4-6). Instruct it to be adversarial and to return findings each tagged **blocking** or **non-blocking**, checking: correctness/bugs, adherence to the approved plan, scope, and missing tests.
- Fix every **blocking** finding, then re-run verification (step 5) and re-stage new changes using `git add -A`.
- Repeat using the same sub-agent until no unresolved blocking findings remain, or 3 rounds have passed.
- If blocking findings remain unresolved after 3 rounds, STOP and present the specific unresolved points to the user.

## 7. Wrap up

- Summarize what was implemented, the verification results, and any non-blocking findings noted along the way that the user may want to address later.
- If the implementation was successful (no user review needed), commit your work to the current branch.
