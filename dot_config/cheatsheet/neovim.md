# Neovim

## Files & search

| Keys | Action |
|---|---|
| `Ctrl+P` | Find files (also insert) |
| `Ctrl+E` | Recent files in this project (also insert) |
| `g n` | Smart picker |
| `Space f f` | Grep the project, or the selection (visual) |
| `Space o s` | Switch project |
| `Space o f` | Resume the last picker |
| `Space k m` | Search keymaps |

## Pickers

| Keys | Action |
|---|---|
| `Esc` | Close the picker, even from insert |
| `Ctrl+J` / `Ctrl+K` | Next / previous item *(built-in)* |
| `Tab` | Select item *(built-in)* |
| `Ctrl+V` / `Ctrl+S` | Open in a vertical / horizontal split *(built-in)* |
| `Ctrl+Q` | Send to the quickfix list *(built-in)* |
| `Alt+P` | Toggle preview *(built-in)* |
| `Alt+H` / `Alt+I` | Toggle hidden / ignored files *(built-in)* |
| `?` | List the picker's keys, from the list *(built-in)* |

## Explorer

| Keys | Action |
|---|---|
| `Space s p` | Reveal the current file |
| `Space o p` | Focus the explorer, opening it if needed |
| `Enter` / `l` | Open the file and keep it (moving only previews) |
| `Esc` | Back to the editor |
| `Ctrl+P` | Find files |
| `h` / `Backspace` | Close folder / go up a folder *(built-in)* |
| `a` | New file, or folder with a trailing `/` *(built-in)* |
| `r` / `d` | Rename / delete *(built-in)* |
| `c` / `m` | Copy / move *(built-in)* |
| `y` / `p` | Yank / paste files *(built-in)* |
| `o` | Open with the system app *(built-in)* |
| `P` | Toggle preview *(built-in)* |
| `H` / `I` | Toggle hidden / ignored files *(built-in)* |
| `Z` | Collapse all folders *(built-in)* |
| `]g` / `[g` | Next / previous git change *(built-in)* |

## Code

| Keys | Action |
|---|---|
| `g d` | Go to definition |
| `Space g i` | Go to implementation |
| `Space f u` | Find usages |
| `Space f s` | Symbols in this file |
| `g s` | Symbols in the workspace |
| `Space r e` | Rename symbol |
| `Ctrl+.` | Code actions (also visual and insert) |
| `Space f d` | Format the file or the selection |
| `Ctrl+/` | Toggle comment on the line or the selection |
| `gc{motion}` | Toggle comment over a motion *(built-in)* |
| `K` | Hover documentation *(built-in)* |
| `Esc` | Close the hover popup |
| `]d` / `[d` | Next / previous diagnostic |
| `Space o d` | Diagnostics list |

## Completion (insert)

| Keys | Action |
|---|---|
| `Tab` | Accept, or jump to the next snippet field |
| `Ctrl+J` / `Ctrl+K` | Next / previous suggestion |
| `Enter` | Accept *(built-in)* |
| `Ctrl+Space` | Show suggestions *(built-in)* |

## Editing

| Keys | Action |
|---|---|
| `Alt+J` / `Alt+K` | Move the line or selection down / up |
| `Alt+Shift+J` | Duplicate the line or selection down |
| `Alt+Shift+L` | Select the word, then grow the selection |
| `Alt+Shift+H` | Shrink the selection (visual) |
| `Ctrl+Backspace` | Delete the word before the cursor (insert) |
| `Y` | Yank to the end of the line |
| `J` | Join lines, keeping the cursor in place |
| `x` / `c` / `C` | Delete or change without touching the clipboard |
| `p` | Paste over the selection, keeping the clipboard (visual) |
| `<` / `>` | Indent and keep the selection (visual) |
| `+` / `-` | Increment / decrement the number |
| `U` | Redo |
| `Q` | Replay macro `q` |
| `ic` | Inner camelCase word (text object) |
| `Space s t` | Split a ternary over three lines |
| `ys{motion}{char}` | Surround *(built-in)* |
| `ds{char}` / `cs{old}{new}` | Delete / change a surrounding pair *(built-in)* |
| `S{char}` | Surround the selection (visual) *(built-in)* |

## Moving around

| Keys | Action |
|---|---|
| `s` | Flash jump (also visual) |
| `g h` / `g l` | Start / end of the line |
| `g m` | Matching pair |
| `[[` / `]]` | Enclosing `{` / `}` |
| `Ctrl+D` / `Ctrl+U` | Half a page down / up, centered |
| `Ctrl+J` / `Ctrl+K` | Scroll one line down / up |
| `n` / `N` | Next / previous match, centered |
| `Space n s` | Clear the search highlight |

## Multiple cursors

| Keys | Action |
|---|---|
| `Ctrl+Alt+J` / `Ctrl+Alt+K` | Add a cursor below / above |
| `Ctrl+Alt+L` | Add a cursor on the next match |
| `Ctrl+Alt+H` | Remove the current cursor |
| `Esc` | Clear the cursors |

## Tabs & windows

| Keys | Action |
|---|---|
| `Alt+H` / `Alt+L` | Previous / next tab (also insert) |
| `Space t c` | Close the tab |
| `Space t o` | Close the other tabs |
| `Space t m` | Close the unchanged tabs |
| `Space t p` | Pin the tab |
| `Space w h/j/k/l` | Move to the window left / down / up / right |
| `Space w s` / `Space w v` | Split horizontally / vertically |
| `Space w c` / `Space w o` | Close the window / the other windows |
| `Space o t` | Toggle the terminal |
| `Space l w` | Toggle line wrap |

## Git

| Keys | Action |
|---|---|
| `Space l g` | Lazygit |
| `Space f h` | File history in lazygit |
| `Space o g` | Changed files |
| `Space g o` | Toggle the inline diff |
| `]h` / `[h` | Next / previous hunk *(built-in)* |

## Build, run & debug

| Keys | Action |
|---|---|
| `Space b a` | Build the solution, errors in the quickfix list |
| `Space b d` | Show the solution's errors without building |
| `Space r a` | Run |
| `Space d a` | Debug |
| `Space s a` | Stop the app or the debug session |
| `Space t b` | Toggle breakpoint |
| `Ctrl+Shift+Alt+K` | Continue |
| `Ctrl+Shift+Alt+J` | Step over |
| `Ctrl+Shift+Alt+L` | Step into |
| `Ctrl+Shift+Alt+H` | Step out |
| `Space e e` | Evaluate the expression under the cursor or the selection |

## Tests (test runner)

| Keys | Action |
|---|---|
| `Space r t` / `Space r T` | Run the test / all tests |
| `Space d t` | Debug the test |
| `Space p s` | Peek the stack trace |
| `g f` | Go to the test's file |

## Session

| Keys | Action |
|---|---|
| `Ctrl+S` | Save all (also insert) |
| `Space c s` | Save all and quit |
| `Space r s` | Restart Neovim |

<!-- omit: <C-_> (terminal alias of <C-/>), i_<C-h> (terminal alias of <C-BS>), vimrc s (replaced by flash), vimrc i_<C-j> i_<C-k> (taken over by blink) -->
