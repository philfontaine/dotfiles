-- Closes every buffer that has neither unsaved changes nor git changes. Modified, added, untracked
-- and renamed files stay open. Outside a git repository, only unsaved changes are considered.

local M = {}

local function changed_files()
  local changed = {}
  local root = vim.fs.root(vim.fn.getcwd(), ".git")
  if not root then
    return changed
  end
  local result = vim.system({ "git", "status", "--porcelain", "-z", "--untracked-files=all" }, { cwd = root }):wait()
  if result.code ~= 0 then
    return changed
  end

  local entries = vim.split(result.stdout, "\0", { trimempty = true })
  local i = 1
  while i <= #entries do
    local status, path = entries[i]:sub(1, 2), entries[i]:sub(4)
    changed[vim.fs.normalize(vim.fs.joinpath(root, path))] = true
    -- Renames and copies are followed by the original path, which is no longer open
    if status:find("[RC]") then
      i = i + 1
    end
    i = i + 1
  end
  return changed
end

function M.close()
  local changed = changed_files()
  Snacks.bufdelete(function(buf)
    local name = vim.fs.normalize(vim.api.nvim_buf_get_name(buf))
    return not vim.bo[buf].modified and not changed[name]
  end)
end

return M
