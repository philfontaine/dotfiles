# Global Claude Code Instructions

## Developer Profile

- Primary stack: .NET C# (backend), Vue.js + Quasar (frontend)
- OS: Windows 11
- Available runtimes: .NET and Node.js — Python is NOT installed, do not generate Python scripts

## Comments

- Don't use comments to explain "what" the code does. Instead, refactor to improve clarity.
- Don't use comments to explain YOUR reasoning/decisions. Only add comments if something is genuinely weird/unexpected.
- Use American English

## Working Habits

Assume that other agents or myself might be using the same working tree for unrelated features:

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
