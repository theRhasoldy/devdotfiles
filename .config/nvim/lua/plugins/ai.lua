local utils = require("config.utils")

vim.cmd([[cab cc CodeCompanion]])

return {
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
      "stevearc/dressing.nvim",
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "gemini",
          },
          inline = {
            adapter = "gemini",
          },
          agent = {
            adapter = "gemini",
          },
        },
        adapters = {
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              env = {
                api_key = os.getenv("GEMINI_API_KEY"),
              },
            })
          end,
        },
        prompt_library = {
          ["Commit Changes"] = {
            strategy = "chat",
            description = "Generate some boilerplate HTML",
            opts = {
              mapping = "<Leader>ch",
            },
            prompts = {
              {
                name = "Commit Changes",
                role = "user",
                opts = { auto_submit = true },
                content = function()
                  -- Leverage auto_tool_mode which disables the requirement of approvals and automatically saves any edited buffer
                  vim.g.codecompanion_auto_tool_mode = true

                  return [[
          /commit @editor commit this message
        ]]
                end,
              },
            },
          },
        },
      })

      -- format after response is done
      local group = utils.create_group("CodeCompanionHooks", {})
      utils.create_autocmd({ "User" }, {
        pattern = "CodeCompanionInline*",
        group = group,
        callback = function(request)
          if request.match == "CodeCompanionInlineFinished" then
            vim.lsp.buf.format({ async = false, bufnr = request.buf })
          end
        end,
      })
    end,
    keys = {
      { "<leader>cc", "<cmd>CodeCompanionChat<cr>", desc = "Code Companion" },
      {
        "<leader>cg",
        "<cmd>CodeCompanion /commit<cr>",
        desc = "Commit using code companion",
      },
    },
  },
  {
    "monkoose/neocodeium",
    event = "VeryLazy",
    ---@module "neocodeium.options"
    opts = {
      silent = true,
      show_labels = false,
      max_lines = 1000,
      filetypes = {
        help = false,
        gitcommit = false,
        gitrebase = false,
        telescope_prompt = false,
      },
    },
    keys = function()
      local neocodeium = require("neocodeium")
      return {
        {
          "<A-g>",
          function()
            neocodeium.accept()
          end,
          mode = "i",
        },
        {
          "<A-w>",
          function()
            neocodeium.accept_word()
          end,
          mode = "i",
        },
        {
          "<A-l>",
          function()
            neocodeium.accept_line()
          end,
          mode = "i",
        },
        {
          "<A-n>",
          function()
            neocodeium.cycle_or_complete()
          end,
          mode = "i",
        },
        {
          "<A-p>",
          function()
            neocodeium.cycle_or_complete(-1)
          end,
          mode = "i",
        },
        {
          "<A-c>",
          function()
            neocodeium.clear()
          end,
          mode = "i",
        },
      }
    end,
  },
}
