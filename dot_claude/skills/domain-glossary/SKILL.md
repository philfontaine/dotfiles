---
name: domain-glossary
description: Maintain a project's GLOSSARY.md of domain terminology, grouped by area. Use when the user asks to update the glossary, define a domain term, or resolve conflicting terminology.
argument-hint: "term to define, and a glossary path if not the repo root"
---

A project's domain language lives in `GLOSSARY.md`. Read [GLOSSARY-FORMAT.md](./GLOSSARY-FORMAT.md) before writing to one — it defines the structure and every rule about the file's content.

`$ARGUMENTS` may name a term, a glossary path, or both. Treat a fragment as a path only if it contains a `/` or ends in `.md`; anything else is the term.

## Which glossary

The repo root `GLOSSARY.md` is the default. A folder or module can also have its own, covering the language used inside it.

- **If the user gives a path, use it.** A directory means the `GLOSSARY.md` inside it; a file path is used as-is.
- **Otherwise use the repo root.** Resolve it with `git rev-parse --show-toplevel`, not the current directory. Don't guess at a scoped glossary from the topic, and never create a new scoped file on your own initiative — the user names the path when they want one.
- **Create only what's asked for.** If the target `GLOSSARY.md` doesn't exist, create it — but only when the user is actually asking for a term to be recorded, never as a side effect of other work, and never with empty groups scaffolded in. If the user names a directory that doesn't exist, stop and ask.

**Every glossary is self-contained.** Never make one defer to a parent — see *Stand on your own* in the format.

## Adding a term

1. **Read the target glossary first.** The concept may already be defined there under a different name. If it is, don't add a second entry — sharpen the existing one.

2. **Reconcile the file with the format.** If the glossary already matches [GLOSSARY-FORMAT.md](./GLOSSARY-FORMAT.md), just add to it.
   - **Missing or stale `## Contents`:** rebuild it from the headings as part of this edit. No need to ask.
   - **Structurally different** (flat list, no groups, terms at `##`): don't silently restructure. Add the term in the file's existing style, then tell the user the file doesn't match the format and offer to convert it as a separate change.

3. **Choose the group it belongs to.** Groups are the `##` headings; terms are `###` headings underneath. Pick the group whose stated scope actually covers the term, not the one that's merely closest.

4. **If no group fits, brainstorm one with the user.** Never invent a group silently — a badly drawn group shapes every term filed under it later. Propose two or three candidate names with their scopes via `AskUserQuestion`, and say which existing terms would move into each.

5. **Write the entry** as a `###` heading under that group, in the position where it reads best — related terms adjacent, not appended to the end by default.

6. **Update the table of contents.** Every group and every term, in document order. This is the step that gets forgotten; do it in the same edit, then re-read the file and confirm every `##` and `###` heading has a matching entry.

## Rules

- **Revise in place.** When a definition turns out to be wrong, fix it. Don't append a corrected duplicate.
- **Push back before writing.** If the term is a general programming concept, a synonym of an entry already in this glossary, or an implementation detail dressed as domain language, say so instead of filing it.
- **Renaming or moving a term touches three places.** The `###` heading, its line in `## Contents` (both text and anchor), and any other definition in the file that names it. Grep the repo for the old name before renaming, and tell the user what else references it.
- **Leave the rest of the file alone.** Fix a stale definition you're touching; don't rewrite unrelated entries in the same edit.

## Challenging terminology

When the user uses a term in a way that contradicts the definition in the glossary for *this* scope, call it out immediately rather than going along with it: "This glossary defines X as A, but you seem to mean B. Which is it?" A glossary nobody enforces is just a file.

When the clash is with a glossary from a different scope — a parent's, or a sibling module's — it is not a conflict. A module may use a term more narrowly than the project at large. Say which scope you're in, and record the local meaning in the local glossary.
