local constants = require("config.constants")

local M = {}

---@class PickPreviewState
---@field win integer|nil Preview float
---@field buf integer|nil Preview scratch buffer
---@field list_win integer|nil mini.pick's list window
---@field items table[]|nil Items currently drawn in the list
---@field item any|nil Item currently drawn in the preview
---@field pending boolean

---@type PickPreviewState
local state = { pending = false }

local function close()
  local win, buf = state.win, state.buf
  state.win, state.buf, state.list_win, state.items, state.item = nil, nil, nil, nil, nil
  if win ~= nil and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  if buf ~= nil and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end

local function render()
  local win, buf = state.win, state.buf
  if win == nil or buf == nil then
    return
  end
  if not (vim.api.nvim_win_is_valid(win) and vim.api.nvim_buf_is_valid(buf)) then
    return close()
  end

  -- mini.pick keeps the cursor on the current item's line, so the row is the
  -- index into the visible slice that `show` last received.
  local row = vim.api.nvim_win_get_cursor(state.list_win)[1]
  local item = (state.items or {})[row]
  if item == nil then
    if state.item == nil then
      return
    end
    state.item = nil
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  else
    -- `show` runs on every keypress, including ones that leave the selection
    -- untouched; re-reading the file then would just burn a redraw.
    if state.item == item then
      return
    end
    state.item = item
    local pick = require("mini.pick")
    -- mini.pick fills in `default_preview` when a source declares none; the
    -- location pickers want the match centred, which only that one accepts.
    local preview = pick.get_picker_opts().source.preview
    if preview == pick.default_preview then
      preview(buf, item, { line_position = "center" })
    else
      preview(buf, item)
      -- CLI-backed previews (git log, git show) fill the buffer from a job
      -- after this returns, while mini.pick blocks in |getcharstr()|.
      vim.defer_fn(function()
        if state.win ~= nil and vim.api.nvim_win_is_valid(state.win) then
          vim.cmd("redraw")
        end
      end, 80)
    end
  end

  -- mini.pick blocks in |getcharstr()| right after drawing the list, so a
  -- preview painted from a scheduled callback stays invisible until the next
  -- keypress unless we flush it ourselves.
  vim.cmd("redraw")
end

local function schedule_render()
  if state.pending then
    return
  end
  state.pending = true
  vim.schedule(function()
    state.pending = false
    render()
  end)
end

local function open()
  -- `state.items` is only set by our own `show`, so the preview never opens
  -- for the pickers that keep mini.pick's defaults.
  if state.win ~= nil or state.items == nil then
    return
  end
  local picker = require("mini.pick").get_picker_state()
  if picker == nil then
    return
  end

  local list_win = picker.windows.main
  local config = vim.api.nvim_win_get_config(list_win)
  -- Only bottom-left anchored floats can be mirrored on the right with the
  -- same row/height; other configs keep mini.pick's own <Tab> preview.
  if config.relative ~= "editor" or config.anchor ~= "SW" then
    return
  end

  -- A float's border is drawn outside `config.col`, so the list's right border
  -- sits at `col + width + 1`; leave one blank column before the panel.
  local list_width = vim.api.nvim_win_get_width(list_win)
  local col = config.col + list_width + 3
  local width = vim.o.columns - col - 2
  if width < 20 then
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"

  state.win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    anchor = "SW",
    style = "minimal",
    border = constants.border,
    width = width,
    height = vim.api.nvim_win_get_height(list_win),
    row = config.row,
    col = col,
    focusable = false,
    noautocmd = true,
  })
  state.buf, state.list_win = buf, list_win

  schedule_render()
end

local function show(buf_id, items, query)
  require("mini.pick").default_show(buf_id, items, query, { show_icons = true })
  state.items = items
  open()
  schedule_render()
end

---Wrap a picker start so the highlighted entry is previewed next to the list.
---
---`start` receives the picker options and must forward them to mini.pick; the
---preview reads the list back through `source.show`, so the picker has to draw
---items in mini.pick's default format for the row lookup to line up.
---@param start fun(opts: MiniPickConfig)
---@return fun()
M.with_preview = function(start)
  return function()
    start({ source = { show = show } })
  end
end

local group = vim.api.nvim_create_augroup("pick_preview", { clear = true })
vim.api.nvim_create_autocmd("User", { pattern = "MiniPickStart", group = group, callback = open })
vim.api.nvim_create_autocmd("User", { pattern = "MiniPickStop", group = group, callback = close })
vim.api.nvim_create_autocmd("WinClosed", {
  group = group,
  callback = function(args)
    local win = tonumber(args.match)
    if win == state.win or win == state.list_win then
      -- Closing a window from another window's WinClosed is not allowed.
      vim.schedule(close)
    end
  end,
})

return M
