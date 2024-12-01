return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "codecompanion", "help" },
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
  opts = {
    preset = "lazy",
    file_types = { "markdown", "codecompanion", "mdx", "help" },
  },
}
