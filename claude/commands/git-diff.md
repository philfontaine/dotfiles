---
allowed-tools: Bash(git diff:*), Bash(git status:*)
argument-hint: [ task description ]
description: Load current git changes as context, then perform a task
---

## Current Staged Changes

!`git diff --cached`

## Current Unstaged Changes

!`git diff`

## Changed Files Summary

!`git status --short`

## Task

$ARGUMENTS