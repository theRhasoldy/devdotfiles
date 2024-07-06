return {
  {
    "joshuadanpeterson/typewriter.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "BufRead",
    config = function()
      local ok, typewriter = pcall(require, "typewriter")

      if(ok) then
        typewriter.setup({
          enable_horizontal_scroll = false,
          enable_notifications = false,
        })

        vim.cmd('TWEnable')
      end
    end,
    keys = {
      {
        "<leader>zz",
        function()
          vim.cmd('TWToggle')
          print("toggled typewriter")
        end,
        desc = "toggle typewriter",
      },
    },
  },
  {
    "karb94/neoscroll.nvim",
    event = "BufReadPre",
    opts = {
      hide_cursor = false,
      easing = "cubic",
    },
  },
}
