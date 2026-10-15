local map = vim.keymap.set

-- Plugin shortcuts
map({ "n", "x" }, "s", function()
  require("flash").jump()
end)
map("n", "gm", "<Plug>(MatchitNormalForward)")
map("x", "gm", "<Plug>(MatchitVisualForward)")

-- Camel case text object
map({ "o", "x" }, "ic", function()
  require("various-textobjs").subword("inner")
end)

-- Comments
map("n", "<C-/>", "gcc", { remap = true })
map("x", "<C-/>", "gc", { remap = true })
map("n", "<C-_>", "gcc", { remap = true })
map("x", "<C-_>", "gc", { remap = true })

-- General IDE shortcuts
map("n", "gd", function()
  Snacks.picker.lsp_definitions()
end)
map("n", "gs", function()
  Snacks.picker.lsp_workspace_symbols()
end)
map("n", "gn", function()
  Snacks.picker.smart()
end)
map({ "n", "i" }, "<C-p>", function()
  Snacks.picker.files()
end)
map({ "n", "i" }, "<C-e>", function()
  Snacks.picker.recent({ filter = { cwd = true } })
end)
map("n", "<Leader>fu", function()
  Snacks.picker.lsp_references()
end)
map("n", "<Leader>gi", function()
  Snacks.picker.lsp_implementations()
end)
map("n", "<Leader>ff", function()
  Snacks.picker.grep()
end)
map("x", "<Leader>ff", function()
  Snacks.picker.grep({
    regex = false,
    search = function(picker)
      return picker:word()
    end,
  })
end)
map("n", "<Leader>re", vim.lsp.buf.rename)
map("n", "<Leader>os", function()
  Snacks.picker.projects()
end)
map("n", "<Leader>cs", "<Cmd>xa<CR>")
map("n", "<Leader>km", function()
  Snacks.picker.keymaps()
end)
map("n", "<Leader>lg", function()
  Snacks.lazygit()
end)
map("n", "<Leader>fh", function()
  Snacks.lazygit.log_file()
end)

-- Save/Cleanup
map("n", "<C-s>", "<Cmd>wall<CR>")
map("i", "<C-s>", "<Cmd>wall<CR><Esc>")
map({ "n", "x" }, "<Leader>fd", function()
  require("conform").format()
end)

-- IDE windows
map("n", "<Leader>sp", function()
  Snacks.explorer.reveal()
  Snacks.picker.get({ source = "explorer" })[1]:focus()
end)
map("n", "<Leader>op", function()
  local explorer = Snacks.picker.get({ source = "explorer" })[1]
  if explorer then
    explorer:focus()
  else
    Snacks.explorer()
  end
end)
map("n", "<Leader>of", function()
  Snacks.picker.resume()
end)
map("n", "<Leader>ot", function()
  Snacks.terminal.toggle("pwsh")
end)

-- Popups
map("n", "<Leader>fs", function()
  Snacks.picker.lsp_symbols()
end)
map({ "n", "x", "i" }, "<C-.>", vim.lsp.buf.code_action)
map("n", "<Esc>", function()
  local preview = vim.b.lsp_floating_preview
  if preview and vim.api.nvim_win_is_valid(preview) then
    vim.api.nvim_win_close(preview, true)
  end
end)

-- Editor navigation
map("n", "<Leader>ne", function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
end)
map("n", "<Leader>pe", function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
end)

-- Build/Run/Debug
map("n", "<Leader>ba", "<Cmd>Dotnet build solution<CR>")
map("n", "<Leader>ra", "<Cmd>Dotnet run default<CR>")
map("n", "<Leader>da", "<Cmd>Dotnet debug default<CR>")
map("n", "<Leader>sa", function()
  local dap = require("dap")
  if dap.session() then
    dap.terminate()
  else
    require("easy-dotnet").stop()
  end
end)
map("n", "<Leader>tb", function()
  require("dap").toggle_breakpoint()
end)
map("n", "<C-S-A-j>", function()
  require("dap").step_over()
end)
map("n", "<C-S-A-k>", function()
  require("dap").continue()
end)
map("n", "<C-S-A-h>", function()
  require("dap").step_out()
end)
map("n", "<C-S-A-l>", function()
  require("dap").step_into()
end)
map({ "n", "x" }, "<Leader>ee", "<Cmd>DapViewHover<CR>")

-- Great stuff from VS Code but without arrow keys
map("i", "<C-BS>", "<C-w>")
-- Terminals send Ctrl+Backspace as <C-h>
map("i", "<C-h>", "<C-w>")
map("n", "<A-S-j>", "<Cmd>t.<CR>")
map("x", "<A-S-j>", ":t'><CR>")
map("n", "<A-j>", "<Cmd>move .+1<CR>==")
map("n", "<A-k>", "<Cmd>move .-2<CR>==")
map("x", "<A-j>", ":move '>+1<CR>gv=gv")
map("x", "<A-k>", ":move '<-2<CR>gv=gv")
map("n", "<A-S-l>", "viw")
map("x", "<A-S-l>", "an", { remap = true })
map("x", "<A-S-h>", "in", { remap = true })
map({ "n", "x" }, "<A-C-j>", function()
  require("multicursor-nvim").lineAddCursor(1)
end)
map({ "n", "x" }, "<A-C-k>", function()
  require("multicursor-nvim").lineAddCursor(-1)
end)
map({ "n", "x" }, "<A-C-l>", function()
  require("multicursor-nvim").matchAddCursor(1)
end)

-- Tab navigation
map({ "n", "i" }, "<A-h>", "<Cmd>BufferLineCyclePrev<CR>")
map({ "n", "i" }, "<A-l>", "<Cmd>BufferLineCycleNext<CR>")
map("n", "<Leader>tc", function()
  Snacks.bufdelete()
end)
map("n", "<Leader>to", function()
  Snacks.bufdelete.other()
end)
map("n", "<Leader>tp", "<Cmd>BufferLineTogglePin<CR>")
map("n", "<Leader>tm", function()
  Snacks.bufdelete(function(buf)
    return not vim.bo[buf].modified
  end)
end)
