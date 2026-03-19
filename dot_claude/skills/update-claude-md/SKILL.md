---
name: update-claude-md
description: Creates or updates a CLAUDE.md file for a project. Use when the user asks to create, generate, initialize or update a CLAUDE.md file. Uses the information provided by the user to fill-in the sections of a pre-defined template (description, structure, important stuff, .
---

# Update CLAUDE.md

Use the information provided by the user to gather additional context and fill in the template sections of the CLAUDE.md
file.

Generate a concise, accurate CLAUDE.md file for the current project by using the information provided by the user and by
gathering additional context related to that information.

If unclear, ask the user which sections need updating.

**Sections:**

- Project description
- Project structure
- Commands
- Key files or directories
- Gotchas

**Principles:**

- One line per concept when possible
- Document non-obvious patterns only — skip what's obvious from the code
- Prefer a short accurate file over a long generic one

**Template:**

```markdown
# <Project Name>

<One-line description of what this project does>

## Project Structure

```

<root>/
  <dir>/    # <purpose>
  <dir>/    # <purpose>
```

## Commands

| Command     | Description   |
|-------------|---------------|
| `<command>` | <description> |

## Key Files or Directories

- `<path>` - <purpose>

## Gotchas

- <non-obvious thing that causes issues>

```
