return {
  "Exafunction/codeium.vim",
  event = "BufEnter",
  config = function()
    vim.g.codeium_disable_bindings = 1
    vim.g.codeium_idle_delay = 50
    vim.g.codeium_render = true
    vim.g.codeium_tab_fallback = ""
  end,
  keys = {
    {
      "<C-g>",
      mode = { "i" },
      function()
        return vim.fn["codeium#Accept"]()
      end,
      expr = true,
      silent = true,
      noremap = true,
      desc = "Accept codeium suggestion",
    },
    {
      mode = { "i" },
      "<C-n>",
      function()
        return vim.fn["codeium#CycleCompletions"](1)
      end,
      expr = true,
      silent = true,
      noremap = true,
      desc = "Cycle forwards codeium suggestion",
    },
    {
      mode = { "i" },
      "<C-p>",
      function()
        return vim.fn["codeium#CycleCompletions"](-1)
      end,
      expr = true,
      silent = true,
      noremap = true,
      desc = "Cycle backwards codeium suggestion",
    },
  },
}
