---
name: timesheet
description: Summarize your git commits across Tecnar repos for the last 13 days, grouped by day. Use when the user asks for a timesheet, weekly summary, or wants to recall what they worked on this week.
model: haiku
disable-model-invocation: true
---

The root directory for all repos is `~/Dev/tecnar`. It holds far more repos than are ever active at
once, so do not scan all of them. Start by finding the ones touched recently:

`find "$HOME/Dev/tecnar" -maxdepth 1 -mindepth 1 -type d -mtime -14`

Then, for each directory that comes back, list the user's commits over the last 13 days across all
local branches. Run one Bash call per repo, in parallel:

`git -C "$HOME/Dev/tecnar/<repo>" log --all --author=pfontaine --since="13 days ago" --pretty=format:"%ad|%s" --date=format:"%Y-%m-%d (%a)"`

Use `$HOME` rather than `~`, which does not expand inside the quotes and makes git fail. A directory
that is not a git repo, or that returns no commits, is simply skipped.

Derive the product name from the repo's folder name: drop any leading `rtw-` or `tfw-` segments,
replace the remaining hyphens with spaces, and title-case it, leaving acronyms uppercase — a folder
ending in `-plc-server` becomes `PLC Server`. When nothing remains after dropping those prefixes,
uppercase the folder name instead.

Then:

1. Merge all results and group commits by date. The date and weekday come directly from git output — use them as-is, do not recompute the weekday.
2. If a date falls on a Saturday or Sunday, merge those commits into the following Monday.
3. For each weekday entry, read all commits and identify the most meaningful work done. Write a short sentence that captures the essence — skip git noise like "fix", "chore", "wip". Think: what would you tell a colleague you worked on that day? Prioritize R&D-flavored work (new algorithms, new features with domain depth). Skip bug fixes and routine maintenance — only mention meaningful work.
4. Always prefix each item with its product name.
5. Sort days oldest first.
6. Write the output to `~/Timesheets/<today-date>.md` using the Write tool, where `<today-date>` is today's date in `yyyy-mm-dd` format.
7. Open the file with `notepad ~/Timesheets/<today-date>.md`.

Output format per day:

```markdown
## Mon, May 4

Prodatalog: KPI endpoint optimization
Controller: Debug mode configuration from database; Weaving aggregator improvements
TFW: Architecture testing framework
```
