-- Keeps C# diagnostics current across files.
--
-- Roslyn flags its diagnostics with `interFileDependencies`: an edit in one file can change the
-- errors of another. Neovim ignores that flag and only pulls diagnostics for the buffer that changed,
-- so after an edit, pull them again for the client's other open buffers.
--
-- `:Dotnet diagnostic` writes a one-time snapshot of the solution's errors into the Roslyn client's
-- push namespace, which Roslyn never updates. Once Roslyn reports on a buffer, drop its snapshot so
-- the live diagnostics replace it.

local roslyn = "easy_dotnet"
local delay_ms = 500
local timers = {}

local function pull(client, bufnr)
  for _, registration in ipairs(client.dynamic_capabilities.capabilities.diagnosticProvider or {}) do
    local identifier = registration.registerOptions.identifier
    if identifier then
      client:request("textDocument/diagnostic", {
        identifier = identifier,
        textDocument = vim.lsp.util.make_text_document_params(bufnr),
      }, nil, bufnr)
    end
  end
end

local function pull_other_buffers(client_id, changed_bufnr)
  local client = vim.lsp.get_client_by_id(client_id)
  for bufnr in pairs(client and client.attached_buffers or {}) do
    if bufnr ~= changed_bufnr and vim.api.nvim_buf_is_loaded(bufnr) then
      pull(client, bufnr)
    end
  end
end

local function schedule_pull_other_buffers(client_id, changed_bufnr)
  local pull_later = vim.schedule_wrap(function()
    pull_other_buffers(client_id, changed_bufnr)
  end)
  timers[client_id] = timers[client_id] or vim.uv.new_timer()
  timers[client_id]:start(delay_ms, 0, pull_later)
end

vim.api.nvim_create_autocmd("LspNotify", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.name == roslyn and ev.data.method == "textDocument/didChange" then
      schedule_pull_other_buffers(client.id, ev.buf)
    end
  end,
})

local on_diagnostic = vim.lsp.handlers["textDocument/diagnostic"]

vim.lsp.handlers["textDocument/diagnostic"] = function(err, result, ctx, config)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if result and client and client.name == roslyn then
    vim.diagnostic.reset(vim.lsp.diagnostic.get_namespace(ctx.client_id), ctx.bufnr)
  end
  return on_diagnostic(err, result, ctx, config)
end
