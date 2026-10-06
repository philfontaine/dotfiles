return {
  "GustavEikaas/easy-dotnet.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
    "mfussenegger/nvim-dap",
  },
  opts = {
    lsp = {
      auto_refresh_codelens = false,
    },
    test_runner = {
      mappings = {
        run_test_from_buffer = { lhs = "<Leader>rt", desc = "run test from buffer" },
        run_all_tests_from_buffer = { lhs = "<Leader>rT", desc = "Run all tests in file" },
        peek_stack_trace_from_buffer = { lhs = "<Leader>ps", desc = "peek stack trace" },
        debug_test_from_buffer = { lhs = "<Leader>dt", desc = "run test from buffer" },
        debug_test = { lhs = "<Leader>dt", desc = "debug test" },
        go_to_file = { lhs = "gf", desc = "go to file" },
        run_all = { lhs = "<Leader>rT", desc = "run all tests" },
        run = { lhs = "<Leader>rt", desc = "run test" },
        peek_stacktrace = { lhs = "<Leader>ps", desc = "peek stacktrace" },
      },
    },
  },
}
