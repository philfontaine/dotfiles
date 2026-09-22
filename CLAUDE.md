# Dotfiles

This repo is managed with [Chezmoi](https://www.chezmoi.io/). Always edit files here, not their applied locations on disk.

## Chezmoi Workflow

After editing any file in this repo, apply it to the live config with `chezmoi apply`:

1. Run `chezmoi apply --dry-run --verbose` first and review the diff.
2. If there are no conflicts, run `chezmoi apply --verbose` for real.
3. If the dry run shows conflicts (e.g. the live file was modified outside chezmoi), stop and surface it instead of applying.

Not everything here is applied by chezmoi. `.chezmoiignore` ignores everything by default and opts paths back in, so `chezmoi managed` is the authority on what a given edit will apply. Notably:

- `dot_claude/tools/` is ignored — it is the source for the binaries in `dot_claude/bin/`, not config. See Claude Tools below.
- `scripts/`, `registry/`, `jetbrains/`, and `dual-key-remap/` are unmanaged. They are run, imported, or copied by hand, so editing them applies nothing.

## Claude Tools

The Claude Code hooks and status line are C# programs in `dot_claude/tools/`, one directory per tool, each a single file-based `.cs` app (no `.csproj`) whose `#:property` directives at the top turn on Native AOT. Each one reads its hook JSON from stdin.

Build them with `scripts/build-claude-tools.ps1`, optionally with `-tool <name>` for a single tool:

- `dotnet publish` emits a self-contained `.exe` per tool into `dot_claude/bin/`, which is gitignored — a fresh clone has to run the script once.
- The script then runs `chezmoi apply --force ~/.claude/bin` itself, so **editing a tool means running the build script**; a plain `chezmoi apply` copies whatever binary was last built.
- Native AOT needs the Visual Studio C++ build tools; the script fails early if `vswhere.exe` is missing.

A tool is only wired up once `dot_claude/settings.json` points a hook or the `statusLine` at its `.exe` in `~/.claude/bin`, and once `scripts/build-claude-tools.ps1` lists it in `$builders`.

## Important Files

### Claude Code

- `dot_claude/CLAUDE.md` — global instructions for every project
- `dot_claude/settings.json`
- `dot_claude/keybindings.json`
- `dot_claude/ShadowBuild.props` — redirects agent dotnet builds out of the repo
- `dot_claude/skills/*`
- `dot_claude/tools/*` — status line and hooks (see Claude Tools)

### VS Code

- `AppData/Roaming/Code/User/settings.json`
- `AppData/Roaming/Code/User/keybindings.json`

### Zed

- `AppData/Roaming/Zed/settings.json`
- `AppData/Roaming/Zed/keymap.json`

### Neovim

- `AppData/Local/nvim/init.vim`

### IdeaVim

- `dot_ideavimrc`

### Obsidian

- `Obsidian/dot_obsidian.vimrc`

### Terminal & OS

- `AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json`
- `dot_config/powershell/profile.ps1` — dot-sourced from `$PROFILE`
- `dual-key-remap/config.txt` — caps lock / escape remapping
- `registry/*.reg` — context menu entries, imported by hand

### JetBrains

- `jetbrains/VSCode VIM PF.xml` — keymap, imported through the IDE
- `jetbrains/keymap.txt`

### Scripts

- `scripts/build-claude-tools.ps1`
- `scripts/update-sourcegit.ps1`
- `scripts/make-link.ps1`
- `scripts/release.ps1`

### Chezmoi

- `.chezmoiignore`
