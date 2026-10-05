return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      close_command = function(buf)
        Snacks.bufdelete(buf)
      end,
      right_mouse_command = function(buf)
        Snacks.bufdelete(buf)
      end,
      diagnostics = "nvim_lsp",
      offsets = {
        { filetype = "snacks_layout_box" },
      },
    },
  },
}
