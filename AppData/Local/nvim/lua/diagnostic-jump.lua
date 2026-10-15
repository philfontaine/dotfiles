-- Jumps between diagnostics across all buffers, not just the current one. Only the most severe
-- level present anywhere is considered: errors while there are any, then warnings, info and hints.
-- Diagnostics are ordered by file path then position, and the jump wraps around at either end.

local M = {}

local function most_severe_diagnostics()
  for severity = vim.diagnostic.severity.ERROR, vim.diagnostic.severity.HINT do
    local diagnostics = vim.diagnostic.get(nil, { severity = severity })
    if #diagnostics > 0 then
      return diagnostics
    end
  end
  return {}
end

local function position_of(diagnostic)
  return { vim.api.nvim_buf_get_name(diagnostic.bufnr), diagnostic.lnum, diagnostic.col }
end

local function is_before(a, b)
  for i = 1, 3 do
    if a[i] ~= b[i] then
      return a[i] < b[i]
    end
  end
  return false
end

---@param direction 1|-1 next or previous
function M.jump(direction)
  local diagnostics = most_severe_diagnostics()
  if #diagnostics == 0 then
    return
  end
  table.sort(diagnostics, function(a, b)
    return is_before(position_of(a), position_of(b))
  end)

  local cursor = vim.api.nvim_win_get_cursor(0)
  local current = { vim.api.nvim_buf_get_name(0), cursor[1] - 1, cursor[2] }
  local target
  if direction > 0 then
    target = diagnostics[1]
    for _, diagnostic in ipairs(diagnostics) do
      if is_before(current, position_of(diagnostic)) then
        target = diagnostic
        break
      end
    end
  else
    target = diagnostics[#diagnostics]
    for i = #diagnostics, 1, -1 do
      if is_before(position_of(diagnostics[i]), current) then
        target = diagnostics[i]
        break
      end
    end
  end

  vim.cmd("normal! m'")
  if target.bufnr ~= vim.api.nvim_get_current_buf() then
    vim.cmd.edit(vim.fn.fnameescape(vim.api.nvim_buf_get_name(target.bufnr)))
  end
  vim.api.nvim_win_set_cursor(0, { target.lnum + 1, target.col })
end

return M
