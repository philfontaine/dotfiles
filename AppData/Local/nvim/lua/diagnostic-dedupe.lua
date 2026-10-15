-- Drops identical items from pulled diagnostic reports. Roslyn reports some syntax errors twice in
-- the same response (like CS1519 for a stray `;`), which would show up twice everywhere.

local function dedupe(items)
  local seen = {}
  local unique = {}
  for _, item in ipairs(items or {}) do
    local key = table.concat({
      item.range.start.line,
      item.range.start.character,
      item.range["end"].line,
      item.range["end"].character,
      tostring(item.severity),
      tostring(item.code),
      item.message,
    }, "\0")
    if not seen[key] then
      seen[key] = true
      table.insert(unique, item)
    end
  end
  return unique
end

local on_diagnostic = vim.lsp.handlers["textDocument/diagnostic"]

vim.lsp.handlers["textDocument/diagnostic"] = function(err, result, ctx, config)
  if result and result.kind == "full" then
    result.items = dedupe(result.items)
  end
  for _, related in pairs(result and result.relatedDocuments or {}) do
    if related.kind == "full" then
      related.items = dedupe(related.items)
    end
  end
  return on_diagnostic(err, result, ctx, config)
end
