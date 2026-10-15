-- Toggles a side-by-side diff of the current file against its last committed version (HEAD).
-- The committed version opens read-only in a split on the left; toggling again, or pressing `q`
-- in that split, closes it and turns diff mode off.

local M = {}

---@type { head_win: integer, source_win: integer }?
local state

local function close()
  local current = state
  state = nil
  if not current then
    return
  end
  if vim.api.nvim_win_is_valid(current.head_win) then
    vim.api.nvim_win_close(current.head_win, true)
  end
  if vim.api.nvim_win_is_valid(current.source_win) then
    vim.api.nvim_win_call(current.source_win, function()
      vim.cmd("diffoff")
    end)
  end
end

local function committed_lines(file)
  local root = vim.fs.root(file, ".git")
  if not root then
    return nil, "Not in a git repository"
  end
  local relative = vim.fs.relpath(root, file)
  local result = vim.system({ "git", "show", "HEAD:" .. relative }, { cwd = root, text = true }):wait()
  if result.code ~= 0 then
    return nil, "Not committed yet: " .. relative
  end
  local lines = vim.split(result.stdout:gsub("\r", ""), "\n")
  if lines[#lines] == "" then
    table.remove(lines)
  end
  return lines, relative
end

function M.toggle()
  if state then
    close()
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return
  end
  local lines, relative = committed_lines(file)
  if not lines then
    vim.notify(relative, vim.log.levels.WARN)
    return
  end

  local source_win = vim.api.nvim_get_current_win()
  local filetype = vim.bo.filetype

  vim.cmd("leftabove vnew")
  local head_win = vim.api.nvim_get_current_win()
  local head_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(head_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_name(head_buf, "HEAD:" .. relative)
  vim.bo[head_buf].buftype = "nofile"
  vim.bo[head_buf].bufhidden = "wipe"
  vim.bo[head_buf].buflisted = false
  vim.bo[head_buf].modifiable = false
  vim.bo[head_buf].filetype = filetype
  vim.cmd("diffthis")
  vim.keymap.set("n", "q", close, { buffer = head_buf })
  vim.api.nvim_create_autocmd("BufWipeout", { buffer = head_buf, once = true, callback = close })

  vim.api.nvim_set_current_win(source_win)
  vim.cmd("diffthis")
  state = { head_win = head_win, source_win = source_win }
end

return M
