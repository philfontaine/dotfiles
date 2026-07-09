# Dotfiles

This repo is managed with [Chezmoi](https://www.chezmoi.io/). Always edit files here, not their applied locations on disk.

## Chezmoi Workflow

After editing any file in this repo, apply it to the live config with `chezmoi apply`:

1. Run `chezmoi apply --dry-run --verbose` first and review the diff.
2. If there are no conflicts, run `chezmoi apply --verbose` for real.
3. If the dry run shows conflicts (e.g. the live file was modified outside chezmoi), stop and surface it instead of applying.

## Important Files

### Claude Code

- `dot_claude/settings.json`
- `dot_claude/keybindings.json`
- `dot_claude/executable_statusline.js`
- `dot_claude/skills/*`

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

- `wezterm/wezterm.lua`
- `AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json`
- `AppData/Local/lazygit/config.yml`

### Chezmoi

- `.chezmoiignore`
