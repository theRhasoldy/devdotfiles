local config_utils = require("config.utils")

local M = {}

M.mode_names = {
  n = "󰹇 ",
  no = "󱠭 ",
  nov = "󱠭 ",
  noV = "󱠭 ",
  ["no\22"] = "󱠭 ",
  niI = "󰹇 i",
  niR = "󰹇 r",
  niV = "󰹇 v",
  nt = "󰹇 t",
  v = "󰛐 ",
  vs = "󰛐 s",
  V = "󰈈 ",
  Vs = "󰈈 s",
  ["\22"] = "󰡭 ",
  ["\22s"] = "󰡭 ",
  s = "S",
  S = "S_",
  ["\19"] = "^S",
  i = "󰏫 ",
  ic = "󰏫 c",
  ix = "󰏫 ",
  R = "",
  r = " ",
  Rc = "󱣩",
  Rx = "󱣩",
  Rv = "󱣩",
  Rvc = "󱣩",
  Rvx = "󱣩",
  c = "󰹇 ",
  cv = "󰹇 ",
  rm = "...",
  ["r?"] = "?",
  ["!"] = "!",
  t = "T",
}

M.git_icons = {
  branch = " ",
  added = " ",
  removed = " ",
  changed = " ",
}

M.sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }

local Align = { provider = "%=" }
local Space = { provider = "  " }
local Padding = { provider = " " }

return {
  "rebelot/heirline.nvim",
  -- enabled = false,
  event = "UIEnter",
  opts = function()
    local ok_conditions, conditions = pcall(require, "heirline.conditions")
    local ok_utils, utils = pcall(require, "heirline.utils")

    if not ok_conditions or not ok_utils then
      print("error loading heirline")
      return
    end

    M.colors = {
      gray = utils.get_highlight("Comment").fg,
      dark_gray = utils.get_highlight("NonText").fg,
      pink = utils.get_highlight("Operator").fg,
      red = utils.get_highlight("Define").fg,
      green = utils.get_highlight("Constant").fg,
      blue = utils.get_highlight("Special").fg,
      orange = utils.get_highlight("Exception").fg,
      purple = utils.get_highlight("Keyword").fg,
    }

    M.mode_colors = {
      n = M.colors.orange,
      i = M.colors.pink,
      v = M.colors.purple,
      V = M.colors.purple,
      ["\22"] = M.colors.purple,
      c = M.colors.orange,
      s = M.colors.blue,
      S = M.colors.blue,
      ["\19"] = M.colors.blue,
      R = M.colors.green,
      r = M.colors.green,
      ["!"] = M.colors.red,
      t = M.colors.red,
    }

    local Diagnostics = {
      condition = conditions.has_diagnostics,
      static = {
        error_icon = config_utils.signs.ERROR,
        warn_icon = config_utils.signs.WARN,
        info_icon = config_utils.signs.INFO,
        hint_icon = config_utils.signs.HINT,
      },
      init = function(self)
        self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        self.warnings =
          #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
        self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
      end,
      update = { "DiagnosticChanged", "BufEnter" },
      {
        provider = " [ ",
        hl = { fg = M.colors.gray },
      },
      {
        provider = function(self)
          -- 0 is just another output, we can decide to print it or not!
          return self.errors > 0 and (self.error_icon .. self.errors .. " ")
        end,
        hl = "Error",
      },
      {
        provider = function(self)
          return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
        end,
        hl = "Warning",
      },
      {
        provider = function(self)
          return self.info > 0 and (self.info_icon .. self.info .. " ")
        end,
        hl = "Info",
      },
      {
        provider = function(self)
          return self.hints > 0 and (self.hint_icon .. self.hints)
        end,
        hl = "Hint",
      },
      {
        provider = "]",
        hl = { fg = M.colors.gray },
      },
    }

    local LSPActive = {
      condition = conditions.lsp_attached,
      update = { "LspAttach", "LspDetach" },
      provider = function()
        local names = {}
        for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
          table.insert(names, server.name)
        end
        return " [ " .. table.concat(names, " ") .. " ]"
      end,
      hl = { fg = M.colors.gray },
    }

    local Git = {
      condition = conditions.is_git_repo,
      init = function(self)
        self.status_dict = vim.b.gitsigns_status_dict
        self.has_changes = self.status_dict.added ~= 0
          or self.status_dict.removed ~= 0
          or self.status_dict.changed ~= 0
      end,
      { -- git branch name
        provider = function(self)
          return M.git_icons.branch .. self.status_dict.head .. " "
        end,
        hl = { fg = M.colors.purple, bold = true },
      },
      -- You could handle delimiters, icons and counts similar to Diagnostics
    }

    local GitChanges = {
      condition = conditions.is_git_repo,
      init = function(self)
        self.status_dict = vim.b.gitsigns_status_dict
        self.has_changes = self.status_dict.added ~= 0
          or self.status_dict.removed ~= 0
          or self.status_dict.changed ~= 0
      end,
      {
        condition = function(self)
          return self.has_changes
        end,
        provider = "[ ",
        hl = { fg = M.colors.gray },
      },
      {
        provider = function(self)
          local count = self.status_dict.added or 0
          return count > 0 and (M.git_icons.added .. count .. " ")
        end,
        hl = "GitSignsAdd",
      },
      {
        provider = function(self)
          local count = self.status_dict.removed or 0
          return count > 0 and (M.git_icons.removed .. count .. " ")
        end,
        hl = "GitSignsDelete",
      },
      {
        provider = function(self)
          local count = self.status_dict.changed or 0
          return count > 0 and (M.git_icons.changed .. count .. " ")
        end,
        hl = "GitSignsChange",
      },
      {
        condition = function(self)
          return self.has_changes
        end,
        provider = "]",
        hl = { fg = M.colors.gray },
      },
    }

    -- Statusline
    local ViMode = {
      update = {
        "ModeChanged",
      },
      -- get vim current mode
      init = function(self)
        self.mode = vim.fn.mode(1) -- :h mode()

        if not self.once then
          vim.api.nvim_create_autocmd("ModeChanged", {
            pattern = "*:*o",
            command = "redrawstatus",
          })
          self.once = true
        end
      end,
      static = {
        mode_names = M.mode_names,
        mode_colors = M.mode_colors,
      },
      provider = function(self)
        return self.mode_names[self.mode] .. "%)"
      end,
      hl = function(self)
        local mode = self.mode:sub(1, 1) -- get only the first mode character
        return { fg = self.mode_colors[mode], bold = true }
      end,
    }

    -- file name parent
    local FileNameBlock = {
      init = function(self)
        self.filename = vim.api.nvim_buf_get_name(0)
      end,
    }

    -- children
    local FileIcon = {
      init = function(self)
        local filename = self.filename
        local extension = vim.fn.fnamemodify(filename, ":e")
        self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(
          filename,
          extension,
          { default = true }
        )
      end,
      provider = function(self)
        return self.icon and (self.icon .. " ")
      end,
      hl = function(self)
        return { fg = self.icon_color }
      end,
    }

    local FileName = {
      provider = function(self)
        local filename = vim.fn.fnamemodify(self.filename, ":.")
        if filename == "" then
          return ""
        end
        if not conditions.width_percent_below(#filename, 0.75) then
          filename = vim.fn.pathshorten(filename)
        end
        return filename
      end,
      hl = { fg = utils.get_highlight("Directory").fg },
    }

    local FileFlags = {
      {
        condition = function()
          return vim.bo.modified
        end,
        provider = " ",
        hl = { fg = M.colors.orange },
      },
      {
        condition = function()
          return not vim.bo.modifiable or vim.bo.readonly
        end,
        provider = " ",
      },
    }

    local FileNameModifer = {
      hl = function()
        if vim.bo.modified then
          -- use `force` because we need to override the child's hl foreground
          return { fg = M.colors.purple, bold = true, force = true }
        end
      end,
    }

    FileNameBlock = utils.insert(
      FileNameBlock,
      FileIcon,
      utils.insert(FileNameModifer, FileName),
      FileFlags,
      Padding,
      { provider = "%<" } -- this means that the statusline is cut here when there's not enough space
    )

    -- cwd in statusline
    local WorkDir = {
      provider = function()
        local icon = (vim.fn.haslocaldir(0) == 1 and " " or " ")
        local cwd = vim.fn.getcwd(0)
        cwd = vim.fn.fnamemodify(cwd, ":h:t") .. "/" .. vim.fn.fnamemodify(cwd, ":t")
        if not conditions.width_percent_below(#cwd, 0.25) then
          cwd = vim.fn.pathshorten(cwd)
        end
        return icon .. "[ " .. cwd .. " ]"
      end,
      hl = { fg = M.colors.gray },
    }

    local Ruler = {
      -- %l = current line number
      -- %L = number of lines in the buffer
      -- %c = column number
      -- %P = percentage through file of displayed window
      provider = "(%L) | %l:%2c | %P",
      hl = { fg = M.colors.gray },
    }

    local ScrollBar = {
      static = {
        sbar = M.sbar,
      },
      provider = function(self)
        local curr_line = vim.api.nvim_win_get_cursor(0)[1]
        local lines = vim.api.nvim_buf_line_count(0)
        local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
        return string.rep(self.sbar[i], 2) -- width
      end,
      hl = { fg = M.colors.gray, bg = M.colors.dark_gray },
    }

    -- Final heirline layout
    local heir = {
      winbar = {
        Diagnostics,
        Align,
        Space,
        FileNameBlock,
        Padding,
      },
      statusline = {
        Padding,
        ViMode,
        Space,
        WorkDir,
        Space,
        Git,
        GitChanges,
        Align,
        LSPActive,
        Space,
        Ruler,
        Space,
        ScrollBar,
        Padding,
      },
      opts = {
        -- if the callback returns true, the winbar will be disabled for that window
        -- the args parameter corresponds to the table argument passed to autocommand callbacks. :h nvim_lua_create_autocmd()
        disable_winbar_cb = function(args)
          return conditions.buffer_matches({
            buftype = { "nofile", "prompt", "help", "quickfix" },
            filetype = { "^git.*", "fugitive", "Trouble", "dashboard" },
          }, args.buf)
        end,
      },
    }

    return heir
  end,
}
