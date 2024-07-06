return {
  "smjonas/inc-rename.nvim",
  cmd = "IncRename",
  config = function ()
    local ok, inc_rename = pcall(require, "inc_rename")

    if ok then
      vim.opt.inccommand = "split"
      inc_rename.setup({
        preview_empty_name = false,
        input_buffer_type = "dressing",
      })
    end
  end,
  keys = {
    {
      mode = { "v", "n" },
      "gR",
      function()
        return ":IncRename " .. vim.fn.expand("<cword>")
      end,
      expr = true,
      noremap = true,
    },
  },
}
