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
- Don't use comments to explain YOUR reasoning/decisions. Only add commments if something is genuinely weird/unexpected.

## Backend (.NET C#)

- Use `dotnet build --no-restore` to compile
- Use `dotnet test` to run tests

## Frontend (Vue.js + Quasar)

- Use `pnpm lint` to lint
- Use `pnpm tsc` to typecheck
- Prefer Composition API (`<script setup>`)
