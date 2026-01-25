return {
  "smjonas/inc-rename.nvim",
  cmd = "IncRename",
  config = function()
    local ok, inc_rename = pcall(require, "inc_rename")

    if not ok then
      print("error loading inc-rename")
      return
    end

    vim.opt.inccommand = "split"
    inc_rename.setup({
      show_message = true,
      input_buffer_type = "dressing",
    })
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
      desc = "Rename under cursor",
    },
  },
}
