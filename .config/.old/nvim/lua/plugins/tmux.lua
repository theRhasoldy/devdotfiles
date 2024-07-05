return {
  "aserowy/tmux.nvim",
  event = "VeryLazy",
  opts = {
    copy_sync = {
      redirect_to_clipboard = true,
    },
    navigation = {
      cycle_navigation = true,
      enable_default_keybindings = true,
    },
  },
  config = function(opts)
    return require("tmux").setup(opts)
  end,
}
