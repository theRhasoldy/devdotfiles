-- Tailwind v4 tokens the language server cannot resolve: the server answers
-- `textDocument/documentColor` only while a `var()` chain stays inside its own
-- theme model, so projects that keep the raw value in `:root` and map it with
-- `@theme inline` get nothing. This module fills exactly that gap, which is why
-- no class is ever painted twice.
--
-- Loading is asynchronous: `lookup()` only reads a cache and the first miss
-- schedules a request; `User TailwindColorsReady` fires once the palette exists
-- (ui.lua repaints on it).

local M = {}

local cache = {} -- project root -> { name = "#hex" }
local pending = {} -- project root -> true while `rg` runs
local roots = {} -- buffer -> project root
local memo = {} -- project root -> { class = "#hex" | false }

local function clamp(value, min, max)
  return math.max(min, math.min(max, value))
end

local function rgb_hex(r, g, b)
  local function channel(value)
    return math.floor(clamp(value + 0.5, 0, 255))
  end
  return ("#%02x%02x%02x"):format(channel(r), channel(g), channel(b))
end

local function hsl_hex(h, s, l)
  h = (h % 360) / 360
  s = clamp(s, 0, 100) / 100
  l = clamp(l, 0, 100) / 100

  local function hue(p, q, t)
    if t < 0 then
      t = t + 1
    elseif t > 1 then
      t = t - 1
    end
    if t < 1 / 6 then
      return p + (q - p) * 6 * t
    elseif t < 1 / 2 then
      return q
    elseif t < 2 / 3 then
      return p + (q - p) * (2 / 3 - t) * 6
    end
    return p
  end

  if s == 0 then
    return rgb_hex(l * 255, l * 255, l * 255)
  end

  local q = l < 0.5 and l * (1 + s) or l + s - l * s
  local p = 2 * l - q
  return rgb_hex(hue(p, q, h + 1 / 3) * 255, hue(p, q, h) * 255, hue(p, q, h - 1 / 3) * 255)
end

local function component(text)
  local cleaned = (text or ""):gsub("%%$", "")
  return tonumber(cleaned)
end

--- Convert a CSS colour literal to `#rrggbb`. Alpha is ignored.
---@param value string
---@return string|nil
local function to_hex(value)
  local v = vim.trim(value)

  if v:sub(1, 1) == "#" then
    local normalised = require("util.shared").normalise_hex(v)
    local digits = normalised:sub(2)
    return (#digits == 6 and not digits:find("%X")) and normalised or nil
  end

  local fn, inner = v:match("^(%a+)%s*%((.*)%)$")
  if fn == nil then
    return nil
  end

  local parts = {}
  for part in (inner:gsub("/", " ")):gmatch("[^,%s]+") do
    parts[#parts + 1] = part
  end
  local a, b, c = component(parts[1]), component(parts[2]), component(parts[3])
  if a == nil or b == nil or c == nil then
    return nil
  end

  fn = fn:lower()
  if fn == "rgb" or fn == "rgba" then
    local scale = parts[1]:find("%%") and 2.55 or 1
    return rgb_hex(a * scale, b * scale, c * scale)
  elseif fn == "hsl" or fn == "hsla" then
    return hsl_hex(a, b, c)
  end
  return nil
end

-- Recursive replacement; the depth guard stops cyclic `var()` chains.
local function resolve(value, vars, depth)
  if depth > 8 then
    return value
  end
  return (
    value:gsub("var%(%s*%-%-([%w_-]+)%s*%)", function(name)
      local raw = vars[name]
      if raw == nil then
        return ""
      end
      return resolve(raw, vars, depth + 1)
    end)
  )
end

-- Whether a value depends on a variable that is not declared inside `@theme`
-- (in which case the language server cannot resolve it).
local function escapes_theme(value, theme_vars, depth)
  if depth > 8 then
    return false
  end
  for name in value:gmatch("var%(%s*%-%-([%w_-]+)%s*%)") do
    if theme_vars[name] == nil then
      return true
    end
    if escapes_theme(theme_vars[name], theme_vars, depth + 1) then
      return true
    end
  end
  return false
end

--- Whether a selector declares a dark palette.
---@param selector string
---@return boolean
local function is_dark(selector)
  local text = selector:lower()
  return text:find("%.dark%f[^%w_-]") ~= nil
    or text:find("%[data%-theme[^%]]*dark") ~= nil
    or text:find("prefers%-color%-scheme%s*:%s*dark") ~= nil
end

--- Collect custom properties in one pass.
---
--- `@theme` declarations are kept apart (the server owns those) and dark blocks
--- are skipped, so swatches show the default palette. A value ends at a
--- top-level `;` or `}`, which covers a block's last declaration when the author
--- omits the semicolon.
---@param css string
---@return table<string, string> theme, table<string, string> rest
local function read_vars(css)
  local theme, rest = {}, {}
  local stack, prelude = {}, {}
  local parens, quote = 0, nil

  local function state()
    return stack[#stack] or { theme = false, dark = false }
  end

  local function flush()
    local text = table.concat(prelude)
    prelude = {}
    local current = state()
    if current.dark then
      return
    end
    local name, value = text:match("^%s*%-%-([%w_-]+)%s*:%s*(.-)%s*$")
    if name ~= nil and value ~= "" then
      local target = current.theme and theme or rest
      target[name] = value
    end
  end

  for index = 1, #css do
    local char = css:sub(index, index)
    if quote ~= nil then
      prelude[#prelude + 1] = char
      if char == quote then
        quote = nil
      end
    elseif char == '"' or char == "'" then
      quote = char
      prelude[#prelude + 1] = char
    elseif char == "(" then
      parens = parens + 1
      prelude[#prelude + 1] = char
    elseif char == ")" then
      parens = math.max(parens - 1, 0)
      prelude[#prelude + 1] = char
    elseif char == "{" then
      local parent = state()
      local selector = table.concat(prelude)
      stack[#stack + 1] = {
        theme = parent.theme or selector:find("@theme", 1, true) ~= nil,
        dark = parent.dark or is_dark(selector),
      }
      prelude = {}
    elseif char == "}" or (char == ";" and parens == 0) then
      flush()
      if char == "}" then
        stack[#stack] = nil
      end
    else
      prelude[#prelude + 1] = char
    end
  end

  return theme, rest
end

--- Build `colour name -> #hex` from CSS text.
---@param css string
---@return table<string, string>
local function parse(css)
  css = css:gsub("/%*.-%*/", "")
  local theme, rest = read_vars(css)
  local all_vars = vim.tbl_extend("force", rest, theme)

  local colors = {}
  for name, value in pairs(theme) do
    if name:sub(1, 6) == "color-" and escapes_theme(value, theme, 0) then
      local hex = to_hex(resolve(value, all_vars, 0))
      if hex ~= nil then
        colors[name:sub(7)] = hex
      end
    end
  end
  return colors
end

local function root_of(bufnr)
  local root = roots[bufnr]
  if root == nil then
    root = require("util.shared").project_root(bufnr)
    roots[bufnr] = root
  end
  return root
end

-- One `rg` pass delivers the whole palette, so no Lua-side file reads.
local function request(root)
  if cache[root] ~= nil or vim.fn.executable("rg") == 0 then
    return
  end

  vim.system({
    "rg",
    "--no-messages",
    "--no-filename",
    "--no-line-number",
    "--sort",
    "path",
    "--glob",
    "*.css",
    "--glob",
    "!node_modules",
    "--glob",
    "!.next",
    "--glob",
    "!dist",
    "--glob",
    "!build",
    "--glob",
    "!out",
    ".",
  }, { cwd = root, text = true }, function(result)
    local ok, colors = pcall(parse, result.code == 0 and result.stdout or "")
    if not ok then
      colors = {}
    end
    vim.schedule(function()
      pending[root] = nil
      cache[root] = colors
      vim.api.nvim_exec_autocmds("User", { pattern = "TailwindColorsReady", data = { root = root } })
    end)
  end)
end

--- Colours resolved for the project at `root`, or nil while it loads.
---@param root string
---@return table<string, string>|nil
local function colors_for(root)
  local colors = cache[root]
  if colors ~= nil then
    return colors
  end

  -- Never block a buffer load: queue the read for the next event-loop turn.
  if not pending[root] then
    pending[root] = true
    vim.schedule(function()
      request(root)
    end)
  end
  return nil
end

--- Hex for a Tailwind class (`bg-primary-500/50`, `hover:text-danger-100`, …).
---@param bufnr integer
---@param class string
---@return string|nil
function M.lookup(bufnr, class)
  local root = root_of(bufnr)
  local colors = colors_for(root)
  if colors == nil then
    return nil
  end

  -- Class spellings repeat far more than they differ, so resolve each once
  -- per palette.
  local known = memo[root]
  if known == nil then
    known = {}
    memo[root] = known
  end
  local hex = known[class]
  if hex ~= nil then
    return hex or nil
  end

  local name = (class:match("([^:]+)$") or class):gsub("^!", ""):gsub("/.*$", "")
  hex = colors[name] or colors[name:match("^[%a]+%-(.+)$") or ""] or false
  known[class] = hex
  return hex or nil
end

local group = vim.api.nvim_create_augroup("tailwind_colors", { clear = true })

vim.api.nvim_create_autocmd("BufDelete", {
  group = group,
  callback = function(args)
    roots[args.buf] = nil
  end,
})

-- A written stylesheet can change the palette; reload it for its project.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  pattern = "*.css",
  callback = function(args)
    local root = require("util.shared").project_root(args.buf)
    if cache[root] == nil then
      return
    end
    cache[root] = nil
    memo[root] = nil
    request(root)
  end,
})

-- Buffer roots are cached per buffer id; a directory change can move them.
vim.api.nvim_create_autocmd("DirChanged", {
  group = group,
  callback = function()
    roots = {}
  end,
})

return M
