---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter").setup()

      vim.schedule(function()
        require("nvim-treesitter").install({
          "tsx",
          "typescript",
          "bash",
          "fish",
          "javascript",
          "astro",
          "css",
          "html",
          "json",
          "yaml",
          "toml",
          "lua",
          "vim",
          "vimdoc",
          "query",
          "markdown",
          "markdown_inline",
          "gitcommit",
          "sql",
        })
      end)

      local ts_indent_ft = require("util.shared").indent_ft

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
        desc = "Start treesitter highlighting",
        callback = function(args)
          -- Skip very large buffers: treesitter highlighting is O(n) and
          -- blocks the first paint; core editing stays fast without it.
          if vim.api.nvim_buf_line_count(args.buf) > 5000 then
            return
          end
          pcall(vim.treesitter.start, args.buf)
          if ts_indent_ft[vim.bo[args.buf].filetype] then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
