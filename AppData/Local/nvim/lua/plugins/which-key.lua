return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    delay = function(ctx)
      if not vim.g.which_key_enabled then
        -- which-key has no off switch, so a day-long delay keeps the popup from showing
        return 24 * 60 * 60 * 1000
      end
      return ctx.plugin and 0 or 200
    end,
  },
}
