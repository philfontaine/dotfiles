local prettier = { "prettier" }

return {
  "stevearc/conform.nvim",
  dependencies = { "mason-org/mason.nvim" },
  opts = {
    formatters_by_ft = {
      css = prettier,
      graphql = prettier,
      handlebars = prettier,
      html = prettier,
      htmlangular = prettier,
      javascript = prettier,
      javascriptreact = prettier,
      json = prettier,
      json5 = prettier,
      jsonc = prettier,
      less = prettier,
      markdown = prettier,
      mdx = prettier,
      scss = prettier,
      typescript = prettier,
      typescriptreact = prettier,
      vue = prettier,
      yaml = prettier,
    },
    default_format_opts = { lsp_format = "fallback" },
  },
  config = function(_, opts)
    require("conform").setup(opts)

    local registry = require("mason-registry")
    registry.refresh(function()
      local package = registry.get_package("prettier")
      if not package:is_installed() then
        package:install()
      end
    end)
  end,
}
