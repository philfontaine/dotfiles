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
                ["q"] = false,
              },
            },
            list = {
              keys = {
                ["<Esc>"] = "focus_editor",
                ["q"] = false,
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
  config = function(_, opts)
    require("snacks").setup(opts)

    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("open-explorer", { clear = true }),
      callback = function()
        if not Snacks.picker.get({ source = "explorer" })[1] then
          Snacks.explorer({ enter = vim.fn.argc() == 0 })
        end
      end,
    })
  end,
}
