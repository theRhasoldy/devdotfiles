---@type LazySpec
return {
  {
    "nickjvandyke/opencode.nvim",
    keys = {
      {
        "<leader>oa",
        function()
          require("opencode").ask("@this: ")
        end,
        mode = { "n", "x" },
        desc = "AI: ask opencode",
      },
      {
        "<leader>os",
        function()
          require("opencode").select()
        end,
        mode = { "n", "x" },
        desc = "AI: opencode select",
      },
    },
    ---@type opencode.Opts
    opts = {},
  },
}
