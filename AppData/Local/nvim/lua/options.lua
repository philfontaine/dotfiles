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
vim.o.titlestring = "%{fnamemodify(getcwd(), ':t')}"
-- globals: bufferline keeps pinned buffers in vim.g.BufferlinePinnedBuffers
vim.o.sessionoptions = "buffers,globals"

vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevelstart = 99

vim.diagnostic.config({ virtual_text = { current_line = true } })

vim.filetype.add({
  extension = {
    axaml = "xml",
    xaml = "xml",
  },
})

-- Windows Terminal resets the cursor shape when its tab regains focus, so resend it
vim.api.nvim_create_autocmd("FocusGained", {
  group = vim.api.nvim_create_augroup("restore-cursor-shape", { clear = true }),
  callback = function()
    local guicursor = vim.o.guicursor
    vim.o.guicursor = ""
    vim.o.guicursor = guicursor
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("two-space-indent", { clear = true }),
  pattern = {
    "css",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "jsonc",
    "lua",
    "scss",
    "typescript",
    "typescriptreact",
    "vue",
  },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
  end,
})

-- Roslyn source-generated documents are virtual, but when easy-dotnet fails to load one it is left
-- as a regular modified buffer, which makes `:xa` try to write its URI to disk
vim.api.nvim_create_autocmd("BufWriteCmd", {
  group = vim.api.nvim_create_augroup("never-write-source-generated", { clear = true }),
  pattern = "roslyn-source-generated://*",
  callback = function(args)
    vim.bo[args.buf].modified = false
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
