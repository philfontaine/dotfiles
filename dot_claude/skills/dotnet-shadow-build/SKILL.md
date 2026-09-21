---
name: dotnet-shadow-build
description: The Shadow Build strategy — how and where agents build .NET projects so they never collide with the user's running app. Use when building or testing any dotnet project, when a build fails with MSB3027/MSB3021 or any file-lock or "being used by another process" error, when tempted to run or launch an app to check a change, or when reasoning about ArtifactsPath, bin/obj locations, or why build output is not where you expected.
---

# Shadow Build

Every dotnet repo on this machine has two output trees.

- **Live tree** — the repo's own `artifacts/` (or `bin/`+`obj/`). It belongs to the user: their running
  app, their hot reload, their IDE. **Agents never write here.**
- **Shadow tree** — `%LOCALAPPDATA%\claude-shadow\<key>\slot-<n>\{bin,obj}`, outside the repo. Agent
  builds go here, so a build works even while the app is running and holding its own output locked.

```
%LOCALAPPDATA%\claude-shadow\
  repo1-314168388\         key: the dir of the NEAREST Directory.Build.props, + a hash of its path
    slot-0\                every agent build, unless a slot is locked
    slot-1\                only after a lock error in slot-0
    slot-lsp\              anything that did not come through an agent's shell — the C# LSP
```

Because the key comes from the nearest `Directory.Build.props`, a submodule that has its own gets its
own key, so a repo with one ends up with both a `repo1-…` and a `submodule1-…` tree. That resolves
consistently and is only a disk cost. `CLAUDE_SHADOW_KEY` pins one key for a whole solution if you
want them merged.

## You normally do nothing

`~/.claude/settings.json` sets `CustomAfterDirectoryBuildProps` to `~/.claude/ShadowBuild.props`, which
redirects `ArtifactsPath` whenever `CLAUDE_CODE=1`. It moves **both `bin` and `obj`**, applies to every
project in the graph, needs no change to any repo, and covers scripts that shell out to `dotnet`. It also
overrides an `ArtifactsPath`, `UseArtifactsOutput=false` or hardcoded `BaseOutputPath`/`OutputPath` that
a repo sets for itself, so those repos redirect too.

`publish` and `pack` are redirected as well (`PublishDir`, `PackageOutputPath`). If you need publish
output inside the repo, pass `-o` explicitly — `dotnet publish` with no `-o` lands in the shadow tree.

So build and test the ordinary way:

```bash
dotnet build Some.App/Some.App.csproj
dotnet test  Some.Tests/Some.Tests.csproj
```

On a machine without that wiring, pass the path yourself — an explicit flag is a global property and
always wins over the props file:

```bash
dotnet build Some.App/Some.App.csproj --artifacts-path "$LOCALAPPDATA/claude-shadow/manual/slot-0"
```

## Rules

**Don't launch the app to check your work.** For an app the user runs — anything with a UI, a service
they have open — build, test, and then *ask them to run it* and tell you what they see. They own the
running app and the visual verification. If runtime behaviour needs covering, write a test.

Nothing enforces this, because it isn't universal: in a prototype, a benchmark or a scratch console
project, running it yourself is the point. Use `dotnet run` freely there. The rule is about not
disturbing an app the user is already running, not a ban on executing code.

**Never pass `--no-restore`.** A cold shadow slot has no `project.assets.json` yet, so it fails outright;
a warm restore costs almost nothing. The hook strips the flag if you pass it anyway.

**Never redirect output to dodge a lock by other means.** Do not reach for `-t:Compile`,
`-t:CoreCompile` or `-t:CompileAvaloniaXaml`; in some repos those leave an assembly without its compiled
XAML and break the app at startup. Shadow Build already removes the lock those flags were working around.

## When a build still fails on a lock

`MSB3027` / `MSB3021` inside the *shadow* tree means another agent is building in the same slot. Escalate
to the next slot, which the hook leaves alone once you set it explicitly:

```bash
CLAUDE_SHADOW_SLOT=1 dotnet build Some.App/Some.App.csproj
```

Then `2`, and so on. Never retry into the live tree. Prefer slot 0 the rest of the time: it stays warm, and
a fresh slot pays for a full restore and rebuild.

## Checking it worked

The invariant is that a shadow build leaves the live tree untouched:

Run it from the repo root — `find artifacts` silently returns nothing from anywhere else, which reads as
a pass. Put the marker in your scratchpad directory, not `/tmp`:

```bash
MARK="$CLAUDE_SCRATCHPAD/mark"       # or the scratchpad path from your environment
cd "$(git rev-parse --show-toplevel)"
touch "$MARK" && sleep 1 && dotnet build Some.App/Some.App.csproj
find artifacts -newer "$MARK" -type f | grep -v /logs/    # expect nothing
```

A running app writes its own logs under the live tree, so exclude those.

Or ask MSBuild directly, which needs no build:

```bash
dotnet msbuild Some.App/Some.App.csproj -getProperty:BaseOutputPath -getProperty:BaseIntermediateOutputPath
```

Both should be under `claude-shadow`. If either points into the repo, `CLAUDE_CODE` is not `1` in this
environment or `CustomAfterDirectoryBuildProps` is not set — check those before assuming the repo is at
fault, and never fall back to building into the live tree.

## Housekeeping

Each slot holds a full copy of the build output (hundreds of MB), so prune slots nobody has touched in a
fortnight:

```bash
find "$LOCALAPPDATA/claude-shadow" -maxdepth 2 -name 'slot-*' -type d -mtime +14
```
