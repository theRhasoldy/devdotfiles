return {
  "cbochs/grapple.nvim",
  opts = {
    scope = "git", -- also try out "git_branch"
  },
  cmd = "Grapple",
  keys = {
    {
      "m",
      function()
        require("grapple").tag()
        require("notify").notify("File tagged")
      end,
      noremap = true,
      desc = "Grapple tag file",
    },
    {
      "<leader>fm",
      "<cmd>Telescope grapple tags<cr>",
      noremap = true,
      desc = "Search grapple tags",
    },
    {
      "<leader>m",
      "<cmd>Grapple toggle_tags<cr>",
      noremap = true,
      desc = "Grapple open tags window",
    },
  },
}
