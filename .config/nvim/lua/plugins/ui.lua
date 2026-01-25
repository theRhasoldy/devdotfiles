local M = {}

M.mode_names = {
  n = "󰹇 ",
  i = "󰏫 ",
  v = "󰛐 ",
  V = "󰈈 ",
  ["\22"] = "󰡭 ",
  c = "󰹇 ",
  s = "S",
  S = "S_",
  ["\19"] = "^S",
  R = "",
  r = " ",
  t = "T",
}
M.git_icons = { branch = " ", added = " ", removed = " ", changed = " " }

return {
  {
    "rebelot/heirline.nvim",
    event = "UIEnter",
    opts = function()
      local conditions = require("heirline.conditions")
      local utils = require("heirline.utils")

      -- Minimal Palette
      local colors = {
        gray = utils.get_highlight("Comment").fg,
        purple = utils.get_highlight("Keyword").fg,
        orange = utils.get_highlight("Exception").fg,
        pink = utils.get_highlight("Operator").fg,
        green = utils.get_highlight("Constant").fg,
        red = utils.get_highlight("Define").fg,
      }

      local Align, Space = { provider = "%=" }, { provider = " " }

      -- 1. Optimized ViMode
      local ViMode = {
        init = function(self)
          self.mode = vim.fn.mode(1)
        end,
        update = { "ModeChanged" },
        provider = function(self)
          return (M.mode_names[self.mode] or "󰹇 ") .. "%)"
        end,
        hl = function(self)
          local m = self.mode:sub(1, 1)
          local color_map = {
            n = colors.orange,
            i = colors.pink,
            v = colors.purple,
            V = colors.purple,
            ["\22"] = colors.purple,
            R = colors.green,
            t = colors.red,
          }
          return { fg = color_map[m] or colors.gray, bold = true }
        end,
      }

      -- 2. Macro Recording Indicator (New)
      local MacroRec = {
        condition = function()
          return vim.fn.reg_recording() ~= ""
        end,
        update = { "RecordingEnter", "RecordingLeave" },
        { provider = " ", hl = { fg = colors.orange, bold = true } },
        {
          provider = function()
            return "@" .. vim.fn.reg_recording()
          end,
          hl = { fg = colors.green, bold = true },
        },
        Space,
      }

      -- 3. Performance-focused FileName
      local FileNameBlock = {
        init = function(self)
          self.filename = vim.api.nvim_buf_get_name(0)
        end,
        {
          provider = function(self)
            local icon, color = require("nvim-web-devicons").get_icon_color(self.filename, nil, { default = true })
            self.icon_color = color
            return icon and (icon .. " ")
          end,
          hl = function(self)
            return { fg = self.icon_color }
          end,
        },
        {
          provider = function(self)
            local f = vim.fn.fnamemodify(self.filename, ":.")
            return f == "" and "[No Name]"
              or (not conditions.width_percent_below(#f, 0.7) and vim.fn.pathshorten(f) or f)
          end,
          hl = function()
            return { fg = utils.get_highlight("Directory").fg, bold = vim.bo.modified }
          end,
        },
        {
          condition = function()
            return vim.bo.modified
          end,
          provider = " ",
          hl = { fg = colors.orange },
        },
      }

      -- 4. Diagnostics with Colors
      local Diagnostics = {
        condition = conditions.has_diagnostics,
        update = { "DiagnosticChanged", "BufEnter" },
        init = function(self)
          self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
          self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
          self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
          self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
        end,
        { provider = " [ ", hl = { fg = colors.gray } },
        {
          provider = function(self)
            return self.errors > 0 and ("󰅚 " .. self.errors .. " ")
          end,
          hl = { fg = colors.red },
        },
        {
          provider = function(self)
            return self.warnings > 0 and ("󰀪 " .. self.warnings .. " ")
          end,
          hl = { fg = colors.orange },
        },
        {
          provider = function(self)
            return self.info > 0 and ("󰋽 " .. self.info .. " ")
          end,
          hl = { fg = colors.purple },
        },
        {
          provider = function(self)
            return self.hints > 0 and ("󰌶 " .. self.hints)
          end,
          hl = { fg = colors.green },
        },
        { provider = "]", hl = { fg = colors.gray } },
      }

      -- 5. Simplified Git (Fixed)
      local Git = {
        condition = conditions.is_git_repo,
        init = function(self)
          -- FALLBACK: Ensure the table exists even if gitsigns isn't ready
          self.status = vim.b.gitsigns_status_dict or { head = "", added = 0, changed = 0, removed = 0 }
        end,
        {
          -- Only show branch if 'head' exists and isn't empty
          condition = function(self)
            return self.status.head and self.status.head ~= ""
          end,
          provider = function(self)
            return M.git_icons.branch .. self.status.head .. " "
          end,
          hl = { fg = colors.purple, bold = true },
        },
        {
          condition = function(self)
            return (self.status.added or 0) + (self.status.removed or 0) + (self.status.changed or 0) > 0
          end,
          provider = function(self)
            local res = "[ "
            if (self.status.added or 0) > 0 then
              res = res .. " " .. self.status.added .. " "
            end
            if (self.status.changed or 0) > 0 then
              res = res .. " " .. self.status.changed .. " "
            end
            if (self.status.removed or 0) > 0 then
              res = res .. " " .. self.status.removed .. " "
            end
            return res .. "]"
          end,
          hl = { fg = colors.gray },
        },
      }

      return {
        statusline = {
          condition = function()
            return not conditions.buffer_matches({
              filetype = { "ministarter", "dashboard", "alpha", "starter", "snacks_dashboard" },
            })
          end,
          Space,
          ViMode,
          Space,
          MacroRec,
          Git,
          Align, -- Added MacroRec here
          { provider = " ", hl = { fg = colors.gray }, condition = conditions.lsp_attached },
          Space,
          FileNameBlock,
          Align,
          { provider = "%l:%c | %P", hl = { fg = colors.gray } },
          Space,
        },
        winbar = { Diagnostics, Align, FileNameBlock },
        opts = {
          disable_winbar_cb = function(args)
            return conditions.buffer_matches({
              buftype = { "nofile", "prompt", "help", "quickfix" },
              filetype = { "^git.*", "fugitive", "Trouble", "dashboard", "nterm", "ministarter" },
            }, args.buf)
          end,
        },
      }
    end,
  },
  {
    "snacks.nvim",
    opts = {
      indent = {
        enabled = false,
      },
      ---@class snacks.dashboard.Config
      ---@field enabled? boolean
      ---@field sections snacks.dashboard.Section
      ---@field formats table<string, snacks.dashboard.Text|fun(item:snacks.dashboard.Item, ctx:snacks.dashboard.Format.ctx):snacks.dashboard.Text>
      dashboard = {
        width = 60,
        -- These settings are used by some built-in sections
        preset = {
          header = [[
     _/\/\/\/\/\____/\/\____/\/\______/\/\________/\/\/\/\/\____/\/\/\/\____/\/\________/\/\/\/\/\____/\/\____/\/\_
    _/\/\____/\/\__/\/\____/\/\____/\/\/\/\____/\/\__________/\/\____/\/\__/\/\________/\/\____/\/\__/\/\____/\/\_
   _/\/\/\/\/\____/\/\/\/\/\/\__/\/\____/\/\____/\/\/\/\____/\/\____/\/\__/\/\________/\/\____/\/\____/\/\/\/\___
  _/\/\__/\/\____/\/\____/\/\__/\/\/\/\/\/\__________/\/\__/\/\____/\/\__/\/\________/\/\____/\/\______/\/\_____
 _/\/\____/\/\__/\/\____/\/\__/\/\____/\/\__/\/\/\/\/\______/\/\/\/\____/\/\/\/\/\__/\/\/\/\/\________/\/\_____
______________________________________________________________________________________________________________]],
        },
        -- item field formatters
        sections = {
          { section = "header" },
          function()
            local in_git = Snacks.git.get_root() ~= nil
            local cmds = {
              {
                title = "Open Issues",
                cmd = "gh issue list -L 3",
                key = "i",
                action = function()
                  vim.fn.jobstart("gh issue list --web", { detach = true })
                end,
                icon = " ",
                height = 5,
              },
              {
                icon = " ",
                title = "Open PRs",
                cmd = "gh pr list -L 3",
                key = "P",
                action = function()
                  vim.fn.jobstart("gh pr list --web", { detach = true })
                end,
                height = 5,
              },
              {
                icon = " ",
                title = "Git Status",
                cmd = "git --no-pager diff --stat -B -M -C",
                height = 10,
              },
            }
            return vim.tbl_map(function(cmd)
              return vim.tbl_extend("force", {
                section = "terminal",
                enabled = in_git,
              }, cmd)
            end, cmds)
          end,
          { section = "startup" },
        },
      },
    },
  },
  {
    "folke/noice.nvim",
    opts = { presets = { bottom_search = true, long_message_to_split = true, lsp_doc_border = true } },
  },
}
