-- Shared helpers and constants used across config/ and plugins/.
-- Single home for cross-cutting small utilities so they are not duplicated
-- (see the DRY items in the nvim audit queue).

local M = {}

-- Project-root resolution with a cwd fallback.
---@param bufnr integer
---@param markers string|string[]
---@return string
function M.root_of(bufnr, markers)
  return vim.fs.root(bufnr, markers) or vim.fn.getcwd()
end

-- Filetype sets shared across modules (single source of truth). The JS/TS
-- core is defined once and composed into the broader sets so members cannot
-- drift between consumers.
M.js_ts = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

local web_only = { "astro", "css", "html", "sass", "scss", "svelte", "vue" }
local web = vim.list_extend({}, web_only)
M.web_filetypes = vim.list_extend(web, M.js_ts)

-- Set form (keys are filetypes) used by the treesitter indent autocmd.
M.indent_ft = { astro = true, html = true }
for _, ft in ipairs(M.js_ts) do
  M.indent_ft[ft] = true
end

-- Expand a 3-digit hex (`#rgb`) to 6 digits (`#rrggbb`). Inputs that are
-- already 6 digits pass through unchanged. Does not validate; callers that
-- need validation check the returned digits.
---@param hex string
---@return string
function M.normalise_hex(hex)
  local digits = hex:sub(2):lower()
  if #digits == 3 then
    digits = digits:gsub("(.)", "%1%1")
  end
  return "#" .. digits
end

-- Project-root resolution with a cwd fallback. Prefers a monorepo root
-- (pnpm-workspace.yaml) over the nearest package.json so shared UI packages'
-- CSS is scanned for app files.
---@param bufnr integer
---@return string
function M.project_root(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    name = vim.fn.getcwd()
  end
  local dir = vim.fs.dirname(vim.fs.normalize(name))
  while dir and dir ~= "" do
    if vim.uv.fs_stat(dir .. "/pnpm-workspace.yaml") then
      return dir
    end
    local parent = vim.fs.dirname(dir)
    if parent == dir then
      break
    end
    dir = parent
  end
  return vim.fs.root(bufnr, { "package.json", ".git" }) or vim.fn.getcwd()
end

return M
