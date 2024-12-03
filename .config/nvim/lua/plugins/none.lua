local utils = require("config.utils")

local async_formatting = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  vim.lsp.buf_request(
    bufnr,
    "textDocument/formatting",
    vim.lsp.util.make_formatting_params({}),
    function(err, res)
      if err then
        local err_msg = type(err) == "string" and err or err.message
        vim.notify("formatting: " .. err_msg, vim.log.levels.WARN)
        return
      end

      -- don't apply results if buffer is unloaded or has been modified
      if
        not vim.api.nvim_buf_is_loaded(bufnr)
        or vim.api.nvim_buf_get_option(bufnr, "modified")
      then
        return
      end

      if res then
        vim.lsp.buf.format({
          async = true,
          bufnr = bufnr,
          filter = function(client)
            return client.name == "null-ls"
          end,
        })
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("silent noautocmd update")
        end)
      end
    end
  )
end

local augroup = utils.create_group("LspFormatting", {})

return {
  "nvimtools/none-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local ok, none = pcall(require, "null-ls")

    if not ok then
      print("error loading none-ls")
      return
    end

    local formatting = none.builtins.formatting
    local diagnostics = none.builtins.diagnostics

    vim.cmd([[cabbrev wq execute "lua vim.lsp.buf.format()" <bar> wq]])

    none.setup({
      debounce = 150,
      sources = {
        formatting.prettierd,
        diagnostics.selene,
        formatting.stylua,
      },
      on_attach = function(_, bufnr)
        utils.clear_autocmd({ group = augroup, buffer = bufnr })
        utils.create_autocmd("BufWritePost", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            async_formatting(bufnr)
          end,
        })
      end,
    })
  end,
}
