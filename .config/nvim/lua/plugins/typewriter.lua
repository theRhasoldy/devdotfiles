return {
  "joshuadanpeterson/typewriter.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = "BufRead",
  config = function()
    local ok, typewriter = pcall(require, "typewriter")

    if(ok) then
      typewriter.setup({
        enable_horizontal_scroll = false,
      })

      vim.cmd('TWEnable')
    end
  end,
}
