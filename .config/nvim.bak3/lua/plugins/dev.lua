return {
  "folke/lazydev.nvim",
  ft = "lua",
  ---@module "lazydev"
  opts = {
    integrations = {
      cmp = false,
      coq = false,
      lspconfig = true,
    },
    enabled = function()
      return vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
    end,
  },
}
