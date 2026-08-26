# Global Claude Code Instructions

## Developer Profile

- Primary stack: .NET C# (backend), Vue.js + Quasar (frontend)
- OS: Windows 11
- Available runtimes: .NET and Node.js — Python is NOT installed, do not generate Python scripts

## General Preferences

- If a refactor helps to implement a feature, plan/propose the refactor first
- If you learned something non-obvious and you think it's worth remembering, propose adding it to the project's CLAUDE.md.

## Comments

- Don't use comments to explain "what" the code does. Instead, refactor to improve clarity.
- Don't use comments to explain YOUR reasoning/decisions. Only add comments if something is genuinely weird/unexpected.
- Use American English

## Working Habits

- Don't create a worktree on your own initiative. I use them occasionally, and I'll set one up and tell you when I do.
- Otherwise assume other agents are editing the same working tree on unrelated features:
  - Uncommitted changes you didn't make are not yours. Never revert, stash, or stage them — stage only files you touched (no `git add -A`, no `git commit -a`).
  - Never run repo-wide destructive commands: `git checkout .`, `git reset --hard`, `git clean`, `git stash`.
  - Build/test failures and file locks may come from another agent's in-flight edit. If a failure is unrelated to your change, report it instead of fixing it.

## Backend (.NET C#)

- Use `dotnet build --no-restore` to compile
- Use `dotnet test` to run tests

## Frontend (Vue.js + Quasar)

- Use `pnpm lint` to lint
- Use `pnpm tsc` to typecheck
- Prefer Composition API (`<script setup>`)
