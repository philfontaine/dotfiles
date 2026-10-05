return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    picker = {
      actions = {
        focus_editor = function(picker)
          vim.api.nvim_set_current_win(picker.main)
        end,
        files = function()
          Snacks.picker.files()
        end,
      },
      sources = {
        explorer = {
          win = {
            input = {
              keys = {
                ["<Esc>"] = "focus_list",
              },
            },
            list = {
              keys = {
                ["<Esc>"] = "focus_editor",
                ["<c-p>"] = "files",
                ["<c-s>"] = false,
                ["<a-h>"] = false,
              },
            },
          },
        },
      },
    },
    explorer = {},
  },
}
