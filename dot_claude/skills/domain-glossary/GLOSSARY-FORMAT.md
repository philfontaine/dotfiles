# GLOSSARY.md Format

`GLOSSARY.md` holds the canonical language of a project's domain. Terms are organized into groups, with a table of contents at the top.

It usually sits at the repo root, covering the whole project. A folder or module can have its own as well — same format either way, but a scoped glossary's intro must name the folder it covers.

## Structure

```md
# Glossary

{One to three sentences: what domain this glossary covers, and what a reader will find below. For a scoped glossary, name the folder or module it covers.}

## Contents

- [{Group Name}](#group-name)
  - [{Term}](#term)
  - [{Term}](#term)
- [{Group Name}](#group-name)
  - [{Term}](#term)

## {Group Name}

{One to three sentences: what area of the domain this group covers, and what its terms have in common.}

### {Term}

{One to three sentences: what the term IS.}

### {Term}

{One to three sentences: what the term IS.}

## {Group Name}

{One to three sentences: what area of the domain this group covers.}

### {Term}

{One to three sentences: what the term IS.}
```

## Rules

- **Groups are `##`, terms are `###`.** Nothing nests deeper. A term that needs sub-terms is really a group — promote it, and rewrite its definition into a group intro saying what the group covers.
- **The contents list mirrors the headings exactly** — every group and every term, in document order.
- **Build anchors the way the renderer does.** Lowercase the heading, delete everything except letters, digits, spaces, hyphens, and underscores, then replace spaces with hyphens: `### Weld Program (Draft)` → `#weld-program-draft`, `### Run-Time Error` → `#run-time-error`. Hyphens and underscores survive; other punctuation does not. When two headings produce the same anchor, the second gets `-1` appended, the third `-2`, in document order.
- **Every group earns its intro.** If you can't say in a sentence what a group covers, the group is wrong.
- **Keep definitions tight.** One to three sentences. Define what the term IS, not how it works or what the code does with it.
- **One canonical term per concept, within this file.** Never define two headings in the same glossary that mean the same thing. This says nothing about other glossaries — see *Stand on your own*.
- **No implementation details.** No class names, file paths, API shapes, or decisions. Those belong elsewhere.
- **Only domain terms.** General programming concepts don't belong, however heavily the project leans on them.
- **Stand on your own.** A glossary never defers to a parent one. A reader of this scope should never have to open another file to understand a term. Defining the same term in more than one glossary is expected, not a mistake. Two glossaries may define it differently, because a module can use a term more narrowly than the project at large — write the meaning that holds *here* rather than copying the parent's wording.
- **Groups are areas of the domain, not layers of the code.** Group by what the terms are about, not by where they're implemented.
- **Use the glossary's own terms inside definitions.** Defining terms in terms of each other is what makes the later ones easy to grasp.
- **A small glossary is a real one.** One group and three terms is a starting point, not a stub. Split a group once it holds terms that clearly belong to two different areas, and never pre-create empty groups in anticipation.
