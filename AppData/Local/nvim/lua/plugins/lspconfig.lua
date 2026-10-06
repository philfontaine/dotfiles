return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "mason-org/mason-lspconfig.nvim",
  },
  config = function()
    vim.lsp.config("vtsls", {
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
      settings = {
        vtsls = {
          tsserver = {
            globalPlugins = {
              {
                name = "@vue/typescript-plugin",
                location = vim.fn.expand("$MASON/packages/vue-language-server/node_modules/@vue/language-server"),
                languages = { "vue" },
                configNamespace = "typescript",
              },
            },
          },
        },
      },
    })

    require("mason-lspconfig").setup({
      ensure_installed = { "vtsls", "vue_ls" },
    })
  end,
}
