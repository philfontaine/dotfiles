-- Shows the errors of the whole solution, like `:Dotnet diagnostic`, but for the solution easy-dotnet
-- already uses for Roslyn and builds instead of asking every time. Falls back to `:Dotnet diagnostic`
-- when the directory has no solution.

local M = {}

local function is_source_file(path)
  return path:match("%.cs$") and not path:match("[/\\]obj[/\\]")
end

local function populate(solution)
  local client = require("easy-dotnet.rpc.rpc").global_rpc_client
  client:initialize(function()
    client.roslyn:get_workspace_diagnostics(solution, false, function(response)
      require("easy-dotnet.diagnostics").populate_diagnostics(response, is_source_file)
    end)
  end)
end

function M.check()
  require("easy-dotnet.current_solution").get_or_pick_solution(function(solution)
    if solution then
      populate(solution)
    else
      vim.cmd("Dotnet diagnostic")
    end
  end)
end

return M
