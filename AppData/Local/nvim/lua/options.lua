vim.o.mouse = ""
vim.o.undofile = true
vim.o.signcolumn = "yes"
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.cursorline = true
vim.o.inccommand = "split"
vim.o.winborder = "rounded"
vim.o.title = true
vim.o.titlestring = "%{fnamemodify(getcwd(), ':t')} - Nvim"

vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevelstart = 99

-- Windows Terminal resets the cursor shape when its tab regains focus, so resend it
vim.api.nvim_create_autocmd("FocusGained", {
  group = vim.api.nvim_create_augroup("restore-cursor-shape", { clear = true }),
  callback = function()
    local guicursor = vim.o.guicursor
    vim.o.guicursor = ""
    vim.o.guicursor = guicursor
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
