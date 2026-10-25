---@type LazySpec
return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Window left" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Window down" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Window up" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Window right" },
      { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Previous window" },
    },
  },
}
