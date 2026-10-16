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

## Cheat Sheet

`dot_config/cheatsheet/*.md` is a hand-curated list of shortcuts, one file per tab, shown with `glow` in the Cheatsheet Terminal window. `neovim.md` covers `dot_vimrc`, `AppData/Local/nvim/lua/keymaps.lua` and the keys set in the plugin specs; `terminal.md` covers the `keybindings` of the Windows Terminal `settings.json`.

**When you add, change or remove a shortcut in one of those, update its row in the same commit.** A key set to `false` only disables a default, so it gets no row.

"Rebuild the cheat sheet" means a full reconcile: every configured mapping has a row or sits in the file's `omit` line, and rows of mappings that no longer exist go. Keep the existing grouping and wording unless asked.

- Sections group by purpose, not by source file, with a `Keys | Action` table each. `dot_vimrc`, `keymaps.lua` and `dot_ideavimrc` use the same section names in the same order, so a new mapping goes in the config section named like its cheat sheet section, and a new section is added to both.
- Keys read like `Space f f`, `Ctrl+P` or `Alt+Shift+J`, and pairs share a row (`Alt+H` / `Alt+L`). The Action names the mode only when it isn't normal mode, e.g. "(visual)" or "(also insert)".
- `*(built-in)*` marks a default the user wants listed even though no config sets it. Never remove one unless asked.
- The `<!-- omit: ... -->` line at the end of a file lists mappings left out on purpose, such as terminal aliases.

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

### Vim

- `dot_vimrc` — keybindings shared by Neovim and IdeaVim, so they stay in vimscript

### Neovim

- `AppData/Local/nvim/init.lua.tmpl` — sources `~/.vimrc`, then loads the Lua config
- `AppData/Local/nvim/lazy-lock.json` — not applied; lazy.nvim updates it in place in this repo, so commit it after `:Lazy update`
- `AppData/Local/nvim/lua/keymaps.lua` — Neovim-only keybindings, sectioned like the cheat sheet
- `AppData/Local/nvim/lua/plugins/*` — one lazy.nvim spec per plugin

### IdeaVim

- `dot_ideavimrc` — sources `~/.vimrc`

### Lazygit

- `AppData/Local/lazygit/config.yml`

### Obsidian

- `Obsidian/dot_obsidian.vimrc`

### Git

- `dot_gitconfig`

### Terminal & OS

- `AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json`
- `dot_config/powershell/profile.ps1` — dot-sourced from `$PROFILE`
- `dot_config/powershell/taskbar-window.ps1` — gives the Launcher, Neovim and Cheatsheet windows their own taskbar button
- `dot_config/cheatsheet/*.md` — shortcut cheat sheet (see Cheat Sheet)
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
