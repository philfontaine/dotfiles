return {
  "saghen/blink.cmp",
  version = "1.*",
  opts = {
    keymap = {
      preset = "enter",
      ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-n>"] = false,
      ["<C-p>"] = false,
    },
  },
}
