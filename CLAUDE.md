# Global Claude Code Instructions

## Developer Profile
- Primary stack: .NET C# (backend), Vue.js + Quasar (frontend)
- OS: Windows 11

## General Preferences
- Write clean, idiomatic code matching the existing style in each project
- Prefer simple, focused changes — avoid over-engineering
- If a refactor helps to implement a feature, plan/propose the refactor first
- Do not add unnecessary comments, docstrings, or boilerplate

## Backend (.NET C#)
- Use `dotnet build` to compile
- Use `dotnet test` to run tests
- Use `dotnet run` to start the app
- Follow existing conventions in the project

## Frontend (Vue.js + Quasar)
- Use `pnpm dev` to start dev server
- Use `pnpm build` to build
- Use `pnpm lint` to lint
- Use `pnpm tsc` to typecheck
- Prefer Composition API (`<script setup>`)
- Check existing components before creating new abstractions

## Per-Project Details
See the project-level CLAUDE.md in each repository root for project-specific
commands, structure, and conventions.
