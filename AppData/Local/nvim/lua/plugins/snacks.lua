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

local preview_buf

local function preview_in_editor(picker, item)
  local main = picker.main
  if not item or item.dir or vim.api.nvim_get_current_win() ~= picker.list.win.win then
    return
  end
  local file = Snacks.picker.util.path(item)
  local existing = vim.fn.bufnr(file)
  if existing ~= -1 and existing == vim.api.nvim_win_get_buf(main) then
    return
  end

  local previous = preview_buf
  local already_open = existing ~= -1 and vim.bo[existing].buflisted and existing ~= previous
  vim.api.nvim_win_call(main, function()
    vim.cmd.edit(vim.fn.fnameescape(file))
  end)
  preview_buf = not already_open and vim.api.nvim_win_get_buf(main) or nil

  if
    previous
    and previous ~= preview_buf
    and vim.api.nvim_buf_is_valid(previous)
    and not vim.bo[previous].modified
    and #vim.fn.win_findbuf(previous) == 0
  then
    Snacks.bufdelete({ buf = previous })
  end
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
        keep_preview = function(_, item)
          if item and not item.dir then
            preview_buf = nil
          end
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
          on_change = preview_in_editor,
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
                ["<CR>"] = { { "keep_preview", "confirm" } },
                ["l"] = { { "keep_preview", "confirm" } },
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
