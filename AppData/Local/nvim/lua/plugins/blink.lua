return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = { "rafamadriz/friendly-snippets" },
  opts = {
    keymap = {
      preset = "enter",
      ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-p>"] = false,
    },
    sources = {
      default = { "lsp", "path", "snippets" },
    },
  },
}
