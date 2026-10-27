-- Window header: the buffer's path, the revision a virtual buffer name carries
-- and the changed-line counts.
--
-- The bar is a plain string rebuilt per event, not a `%{}` expression, so a
-- redraw costs nothing beyond Vim's native `%<`, `%=` and `%m` items. `%m` is
-- the modified flag, which is why edits need no repaint of their own.

local M = {}

---@class winheader.Color
---@field fg string Group whose foreground the header borrows
---@field bold boolean|nil

---@class winheader.Opts
---@field exclude_buftypes table<string, boolean> Buffers that get no header
---@field prefix string Headers this plugin wrote start with it
---@field resolvers (fun(name: string): string|nil)[] Turn a buffer name into a label; first hit wins
---@field counts fun(buf: integer): string Right-aligned text; empty for none
---@field colors { active: winheader.Color, inactive: winheader.Color }

---@type winheader.Opts
local defaults = {
  -- `nowrite` is deliberately allowed: codediff's revision buffers use it and
  -- still carry a path in their URI.
  exclude_buftypes = { nofile = true, prompt = true, terminal = true, quickfix = true, help = true },
  prefix = "%<",
  resolvers = {
    function(name)
      local path = name:match("^minifiles://%d+/(.*)$")
      return path and vim.fn.fnamemodify(path, ":~:.")
    end,
    function(name)
      -- codediff:///<root>///<revision>/<path>: once the session clears its own
      -- headers, the buffer name is the only place the revision survives.
      local _, revision, path = name:match("^codediff:///(.-)///([^/]+)/(.+)$")
      if path == nil then
        return nil
      end
      local caret = revision:sub(-1) == "^" and "^" or ""
      local sha = caret == "" and revision or revision:sub(1, -2)
      if #sha > 7 and sha:match("^%x+$") then
        revision = sha:sub(1, 7) .. caret
      end
      return path .. " (" .. revision .. ")"
    end,
  },
  -- gitsigns publishes its summary per buffer; mini.diff would read
  -- `vim.b[buf].minidiff_summary_string` here instead.
  counts = function(buf)
    return vim.b[buf].gitsigns_status or ""
  end,
  colors = {
    active = { fg = "Normal", bold = true },
    inactive = { fg = "Comment" },
  },
}

---@param name string
---@param resolvers (fun(name: string): string|nil)[]
---@return string
local function label(name, resolvers)
  for _, resolve in ipairs(resolvers) do
    local resolved = resolve(name)
    if resolved ~= nil then
      return resolved
    end
  end
  return vim.fn.fnamemodify(name, ":~:.")
end

---@param win integer
---@param opts winheader.Opts
---@return string
local function render(win, opts)
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    return ""
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if opts.exclude_buftypes[vim.bo[buf].buftype] then
    return ""
  end
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    return ""
  end
  -- A literal % in the path would be read as a statusline item; `%<` drops the
  -- left of a long path and `%=` right-aligns the counts. The counts come from
  -- this window's buffer, not from `vim.b` (the focused buffer), which would
  -- print one pane's counts in every pane until it gained focus.
  local text = label(name, opts.resolvers):gsub("%%", "%%%%")
  local changed = opts.counts(buf)
  return opts.prefix .. " " .. text .. "%m%=" .. (changed == "" and "" or changed .. " ")
end

---@param win integer
---@param opts winheader.Opts
local function apply(win, opts)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  local current = vim.wo[win].winbar
  -- Anything that is not ours belongs to another plugin (codediff labels its
  -- merge result and conflict panes itself) and is left alone. `:split` copies
  -- window-local options, so an inherited header carries the prefix too.
  if current ~= "" and not vim.startswith(current, opts.prefix) then
    return
  end
  local bar = render(win, opts)
  if current ~= bar then
    vim.wo[win].winbar = bar
  end
end

---@return integer[]
local function windows()
  local wins = {}
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    vim.list_extend(wins, vim.api.nvim_tabpage_list_wins(tab))
  end
  return wins
end

-- Re-render every header, e.g. after swapping `counts` at runtime.
function M.refresh()
  for _, win in ipairs(windows()) do
    apply(win, M.opts)
  end
end

---@param spec winheader.Color
---@return table
local function highlight(spec)
  local source = vim.api.nvim_get_hl(0, { name = spec.fg, link = false })
  return { fg = source.fg, bg = source.bg, bold = spec.bold }
end

---@param opts winheader.Opts|nil
function M.setup(opts)
  -- Shallow on purpose: `resolvers` and `colors` are replaced whole, not merged
  -- index by index the way `tbl_deep_extend` would.
  M.opts = vim.tbl_extend("force", defaults, opts or {})

  local group = vim.api.nvim_create_augroup("winheader", { clear = true })

  -- Themes ship WinBar/WinBarNC dim by default (cendre: `fg_dim` and the gutter
  -- colour), so both states borrow a text colour instead.
  local function colors()
    vim.api.nvim_set_hl(0, "WinBar", highlight(M.opts.colors.active))
    vim.api.nvim_set_hl(0, "WinBarNC", highlight(M.opts.colors.inactive))
  end
  colors()
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, desc = "Colour the window header", callback = colors })

  -- Some plugins clear the winbar of their own windows from these events
  -- (codediff does), so the header is rewritten after that pass, not during it.
  vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter", "WinEnter", "FileType" }, {
    group = group,
    desc = "Window header",
    callback = function()
      local win = vim.api.nvim_get_current_win()
      vim.schedule(function()
        apply(win, M.opts)
      end)
    end,
  })

  -- Counts land after the first paint and after every edit, so they are written
  -- into the bar here rather than read on each redraw.
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "GitSignsUpdate",
    desc = "Refresh window header counts",
    callback = function()
      vim.schedule(M.refresh)
    end,
  })

  M.refresh()
end

return M
