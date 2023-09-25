return {
  "ThePrimeagen/harpoon",
  opts = {
    global_settings = {
      excluded_filetypes = { "harpoon", "TelescopePrompt", "cmp_docs", "cmp_menu", "noice", "notify" },
    },
  },
  keys = {
    {
      "m",
      function()
        require("harpoon.mark").add_file()
        require("notify")("File marked", "info", {
          title = "Harpoon",
        })
      end,
      desc = "Mark current file with Harpoon",
    },
    {
      "<leader>m",
      function()
        require("telescope").extensions.harpoon.marks({
          initial_mode = "normal",
        })
      end,
      desc = "List marks in current project",
    },
  },
}
