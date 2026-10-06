local ns = vim.api.nvim_create_namespace("eol-codelens")

local function render(bufnr, lenses)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local titles_by_row = {}
  for _, lens in ipairs(lenses) do
    if lens.command and lens.command.title ~= "" then
      local row = lens.range.start.line
      titles_by_row[row] = titles_by_row[row] or {}
      table.insert(titles_by_row[row], lens.command.title)
    end
  end

  for row, titles in pairs(titles_by_row) do
    pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, row, 0, {
      virt_text = { { table.concat(titles, " | "), "LspCodeLens" } },
      virt_text_pos = "eol",
    })
  end
end

local function refresh(client, bufnr)
  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
  client:request("textDocument/codeLens", params, function(err, lenses)
    if err or not lenses then
      return
    end

    local pending = #lenses
    if pending == 0 then
      render(bufnr, lenses)
      return
    end

    local function resolved_one()
      pending = pending - 1
      if pending == 0 then
        render(bufnr, lenses)
      end
    end

    for i, lens in ipairs(lenses) do
      if lens.command then
        resolved_one()
      else
        client:request("codeLens/resolve", lens, function(_, resolved)
          lenses[i] = resolved or lens
          resolved_one()
        end, bufnr)
      end
    end
  end, bufnr)
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("eol-codelens", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or not client:supports_method("textDocument/codeLens", args.buf) then
      return
    end

    refresh(client, args.buf)
    vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "BufWritePost", "CursorHold" }, {
      group = vim.api.nvim_create_augroup("eol-codelens-" .. args.buf, { clear = true }),
      buffer = args.buf,
      callback = function()
        if not client:is_stopped() then
          refresh(client, args.buf)
        end
      end,
    })
  end,
})
