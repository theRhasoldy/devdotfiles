return {
  {
    "hrsh7th/nvim-insx",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("insx.preset.standard").setup()
    end,
  },
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup({
        -- Use treesitter-commentstring to detect comments in jsx, astro... etc
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },
  {
    "monaqa/dial.nvim",
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.constant.new({
            elements = { "and", "or" },
            word = true, -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
            cyclic = true, -- "or" is incremented into "and".
          }),
          augend.constant.new({
            elements = { "&&", "||" },
            word = false,
            cyclic = true,
          }),
          augend.constant.new({
            elements = { "true", "false" },
            word = true,
            cyclic = true,
          }),
          augend.hexcolor.new({
            case = "lower",
          }),
          augend.constant.new({
            elements = { "let", "const" },
            word = true,
            cyclic = true,
          }),
        },
        visual = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.constant.alias.alpha,
          augend.constant.alias.Alpha,
        },
      })
    end,
    keys = {
      {
        mode = { "v", "n" },
        "+",
        function()
          return require("dial.map").inc_normal()
        end,
        expr = true,
        noremap = true,
      },
      {
        mode = { "v", "n" },
        "_",
        function()
          return require("dial.map").dec_normal()
        end,
        expr = true,
        noremap = true,
      },
    },
  },
  {
    "sontungexpt/stcursorword",
    event = "VeryLazy",
    config = true,
  },
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    opts = {
      preview_empty_name = true, -- whether an empty new name should be previewed; if false the command preview will be cancelled instead
    },
    keys = {
      {
        mode = { "v", "n" },
        "gr",
        function()
          return ":IncRename " .. vim.fn.expand("<cword>")
        end,
        expr = true,
        noremap = true,
      },
    },
  },
}
