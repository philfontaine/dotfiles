local function restore_session()
  local explorer = Snacks.picker.get({ source = "explorer" })[1]
  if explorer then
    explorer:close()
  end
  require("persistence").load()
  -- Sessions always restore the argument list, so `nvim .` would bring the folder back as a buffer
  vim.cmd("silent! %argdelete")
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.isdirectory(vim.api.nvim_buf_get_name(buf)) == 1 then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  Snacks.explorer({ enter = vim.api.nvim_buf_get_name(0) == "" })
end

local function opened_folder()
  if vim.fn.argc() == 0 then
    return "."
  end
  if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
    return vim.fn.argv(0)
  end
end

return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    picker = {
      win = {
        input = {
          keys = {
            ["<Esc>"] = { "cancel", mode = { "n", "i" } },
          },
        },
      },
      actions = {
        focus_editor = function(picker)
          vim.api.nvim_set_current_win(picker.main)
        end,
        files = function()
          Snacks.picker.files()
        end,
      },
      sources = {
        projects = {
          confirm = function(picker, item)
            picker:close()
            if not item then
              return
            end
            vim.cmd("silent! wall")
            require("persistence").save()
            Snacks.bufdelete.all()
            vim.fn.chdir(item.file)
            restore_session()
            if vim.api.nvim_buf_get_name(0) == "" then
              Snacks.picker.files()
            end
          end,
        },
        explorer = {
          win = {
            input = {
              keys = {
                ["<Esc>"] = { "focus_list", mode = { "n", "i" } },
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
    input = {},
    styles = {
      input = {
        relative = "cursor",
        row = -3,
        col = 0,
      },
    },
  },
  config = function(_, opts)
    require("snacks").setup(opts)

    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("restore-project", { clear = true }),
      nested = true,
      callback = function()
        local folder = opened_folder()
        if folder then
          vim.fn.chdir(folder)
          restore_session()
        elseif not Snacks.picker.get({ source = "explorer" })[1] then
          Snacks.explorer({ enter = false })
        end
      end,
    })
  end,
}
