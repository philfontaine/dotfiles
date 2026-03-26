# VSCode Vim — Unmapped / Incompatible Bindings

## No VSCode Equivalent

### `gn` → `ReSharperNavigateTo`
Rider/ReSharper-specific. No general navigation equivalent in VSCode.

### `<leader>gr` → `GotoRelated`
IntelliJ-specific concept (navigate to related symbols). No direct VSCode equivalent.

### `<leader>ac` → `RiderDebuggerApplyEncChanges`
Rider-specific "Apply Encode Changes" debugger action. No VSCode equivalent.

### `<leader>ta` → `VimFindActionIdAction`
IdeaVim-specific tool for discovering action IDs. No VSCode equivalent.

### `[f` / `]f` → `MethodUp` / `MethodDown`
Navigate between methods/functions in a file. VSCode has no built-in command for this.
Workaround: use `<leader>fs` (File Structure popup via `workbench.action.gotoSymbol`) to navigate to a method.

### `<leader>og` → `:!wt lg`
### `<leader>cl` → `:!wt claude`
Shell commands that open Windows Terminal tabs. VSCode Vim doesn't support `:!` shell execution the same way.
Workaround: define VSCode Tasks in `.vscode/tasks.json` and bind them via `workbench.action.tasks.runTask`.

---

## Approximate / Degraded Mappings

### `gc` → `GotoClass` → mapped to `workbench.action.showAllSymbols`
IntelliJ's GotoClass searches only class types. VSCode's ShowAllSymbols searches all symbols workspace-wide (no type filter). Use `#` prefix in Quick Open for a similar experience.

### `<leader>il` → `Inline` refactor → mapped to `editor.action.refactor`
### `<leader>iv` → `IntroduceVariable` → mapped to `editor.action.refactor`
Both open the generic refactor menu instead of jumping directly to the specific action. Select the desired refactoring from the menu.

### `<leader>cc` → `SilentCodeCleanup` → mapped to `editor.action.fixAll`
Rider's Code Cleanup runs a configurable set of inspections silently. `editor.action.fixAll` applies all auto-fixable problems but is not equivalent.

### `<leader>hw` → `HideAllWindows` → mapped to `workbench.action.toggleSidebarVisibility`
IntelliJ hides all tool windows. VSCode has no single command to hide all panels/sidebar simultaneously; this only toggles the sidebar.

### `<leader>os` → `RecentProjectListGroup` → mapped to `workbench.action.openRecent`
IntelliJ shows a grouped list of recent projects. VSCode's openRecent shows recent folders/workspaces in a flat list.

---

## Not Supported in VSCodeVim

### Camel case text objects (`vic`, `cic`, `dic`, `yic`)
VSCodeVim has no built-in camel case text object support.
Options:
- Install the **"Vim Camel Case Motion"** or **"CamelCaseMotion"** VSCode extension
- The `vim-textobj-variable-segment` plugin behavior is not available

### `gm` → `MatchitMotion`
`vim.matchit` is enabled (via `vim.surround`), but there is no `gm` binding. Use `%` for matchit-style bracket/tag matching.

### `sethandler` directives
IdeaVim's `sethandler` (to control which keys are handled by vim vs IDE) has no equivalent in VSCodeVim. Key conflict resolution is managed via `vim.handleKeys` in settings.json.

### `ideajoin`
IdeaVim's smart join behavior (e.g., joining strings). VSCodeVim's `J` performs standard vim join only.

---

## Bindings Not Ported (Editor-Specific / Obsolete in VSCode)

| Binding | Reason |
|---------|--------|
| `<leader>ev` / `<leader>sv` | Edit/source `.vimrc` — not applicable in VSCode |
| `<leader>ei` / `<leader>si` | Edit/source `.ideavimrc` — not applicable in VSCode |
| `imap <C-n> <Nop>` / `imap <C-p> <Nop>` | Disabled in vim to break habits — VSCodeVim handles these differently; omitted |
| `map <Up/Down/Left/Right> <Nop>` | Arrow key discipline — VSCodeVim doesn't intercept arrow keys by default; omitted |
