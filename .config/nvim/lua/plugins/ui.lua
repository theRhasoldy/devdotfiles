local constants = require("config.constants")
local branch_cache = {}

local function compute_branch(dir)
  local root = vim.fs.root(vim.fs.normalize(dir), ".git")
  if root == nil or vim.fn.executable("git") == 0 then
    return ""
  end
  local out = vim.fn.system({ "git", "-C", root, "symbolic-ref", "--short", "HEAD" })
  if vim.v.shell_error ~= 0 or vim.trim(out) == "" then
    out = vim.fn.system({ "git", "-C", root, "rev-parse", "--short", "HEAD" })
  end
  return vim.trim(out)
end

---@param name string
---@return string|nil
local function minifiles_path(name)
  local path = name:match("^minifiles://%d+/(.*)$")
  return path and vim.fs.normalize(path)
end

local function statusline_dir()
  local files = package.loaded["mini.files"]
  if files ~= nil and files.get_explorer_state() ~= nil then
    local ok, entry = pcall(files.get_fs_entry)
    local path = ok and entry and entry.path or ""
    if path == "" then
      path = minifiles_path(vim.api.nvim_buf_get_name(0)) or ""
    elseif entry.fs_type == "file" then
      path = vim.fs.dirname(path)
    end
    return vim.fs.normalize(path)
  end

  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return vim.fn.getcwd()
  end
  return minifiles_path(name) or vim.fs.dirname(name)
end

-- mini.statusline prints "Normal"/"Visual"/...; the icon map keeps its highlight
-- but swaps the word. `vim.fn.mode()` can return compound values ('no', 'niI'),
-- so fall back to the first character.
local function section_mode()
  local statusline = require("mini.statusline")
  local mode, mode_hl = statusline.section_mode({ trunc_width = 0 })
  local current = vim.fn.mode()
  return constants.modes[current] or constants.modes[current:sub(1, 1)] or mode, mode_hl
end

local function section_git()
  local branch = vim.b.gitsigns_head
  if branch == nil or branch == "" then
    local dir = statusline_dir()
    if branch_cache[dir] == nil then
      branch_cache[dir] = compute_branch(dir)
    end
    branch = branch_cache[dir]
  end
  if branch == nil or branch == "" then
    return ""
  end
  return (require("mini.statusline").config.use_icons and constants.git_branch or "Git") .. " " .. branch
end

---Per-severity segments instead of mini's single string: each count keeps the
---theme's `Diagnostic*` colour, and the glyph/number pair stays separated.
---@return { hl: string, strings: string[] }[]
local function section_diagnostics()
  local statusline = require("mini.statusline")
  if statusline.is_truncated(75) then
    return {}
  end

  local counts = vim.diagnostic.count(0)
  local groups = {}
  for severity, entry in ipairs(constants.diagnostics) do
    local n = counts[severity] or 0
    if n > 0 then
      groups[#groups + 1] = { hl = "Diagnostic" .. entry.name, strings = { entry.glyph .. " " .. n } }
    end
  end
  return groups
end

-- The dashboard's git block is a snapshot taken when the buffer is drawn:
-- mini.starter has no terminal or async sections, so every line is rendered as
-- an inactive item (no action) and refreshed only when the dashboard opens.
---@return MiniStarterItem[]
local function dashboard_git()
  local root = vim.fs.root(vim.fn.getcwd(), ".git")
  if root == nil or vim.fn.executable("git") == 0 then
    return {}
  end

  ---@type MiniStarterItem[]
  local items = {}
  local function add(name)
    items[#items + 1] = { name = name, action = "", section = "Git" }
  end

  local status = vim.fn.systemlist({ "git", "-C", root, "status", "--short", "--branch" })
  if vim.v.shell_error ~= 0 then
    return {}
  end
  -- `## main...origin/main [ahead 1, behind 2]`: keep the branch, condense the
  -- tracking state to arrows so the line stays inside the dashboard width.
  local head = ((status[1] or ""):gsub("^## ", ""))
  local marks = {}
  local ahead, behind = head:match("ahead (%d+)"), head:match("behind (%d+)")
  if ahead then
    marks[#marks + 1] = "↑" .. ahead
  end
  if behind then
    marks[#marks + 1] = "↓" .. behind
  end

  local branch = vim.split(head, "...", { plain = true })[1]:gsub("^No commits yet on ", "")
  add(constants.git_branch .. " " .. branch .. (#marks > 0 and " " .. table.concat(marks, " ") or ""))

  local changes = vim.list_slice(status, 2)
  vim.list_extend(
    items,
    vim.tbl_map(function(line)
      return { name = line, action = "", section = "Git" }
    end, vim.list_slice(changes, 1, 5))
  )
  if #changes > 5 then
    add(("+%d more"):format(#changes - 5))
  end

  -- `HEAD` needs a commit, so a fresh repository has no summary to show.
  local stat = vim.trim(vim.fn.system({ "git", "-C", root, "diff", "HEAD", "--shortstat" }))
  if vim.v.shell_error == 0 and stat ~= "" then
    add(stat)
  end
  if #items == 1 then
    add("working tree clean")
  end
  return items
end

---@return MiniStarterItem[]
local function dashboard_recent()
  local cwd = vim.fn.getcwd() .. "/"
  ---@type MiniStarterItem[]
  local items = {}
  local seen = {}
  for _, path in ipairs(vim.v.oldfiles) do
    if #items == 5 then
      break
    end
    if not seen[path] and vim.startswith(path, cwd) and vim.fn.filereadable(path) == 1 then
      seen[path] = true
      items[#items + 1] = {
        name = vim.fn.fnamemodify(path, ":~:."),
        action = "edit " .. vim.fn.fnameescape(path),
        section = "Recent",
      }
    end
  end
  return items
end

---@type LazySpec
return {
  {
    -- Startup: the first statusline and blink's kind icons need it.
    "nvim-mini/mini.icons",
    lazy = false,
    opts = {},
  },
  {
    -- Startup: opens itself from a VimEnter autocmd that setup() registers, and
    -- an autocmd added while an event runs does not fire for that event.
    "nvim-mini/mini.starter",
    lazy = false,
    ---@type MiniStarterConfig
    opts = {
      header = [[

     _/\/\/\/\/\____/\/\____/\/\______/\/\________/\/\/\/\/\____/\/\/\/\____/\/\________/\/\/\/\/\____/\/\____/\/\_
    _/\/\____/\/\__/\/\____/\/\____/\/\/\/\____/\/\__________/\/\____/\/\__/\/\________/\/\____/\/\__/\/\____/\/\_
   _/\/\/\/\/\____/\/\/\/\/\/\__/\/\____/\/\____/\/\/\/\____/\/\____/\/\__/\/\________/\/\____/\/\____/\/\/\/\___
  _/\/\__/\/\____/\/\____/\/\__/\/\/\/\/\/\__________/\/\__/\/\____/\/\__/\/\________/\/\____/\/\______/\/\_____
 _/\/\____/\/\__/\/\____/\/\__/\/\____/\/\__/\/\/\/\/\______/\/\/\/\____/\/\/\/\/\__/\/\/\/\/\________/\/\_____
______________________________________________________________________________________________________________
]],
      footer = "",
      items = { dashboard_git, dashboard_recent },
    },
    ---@param opts MiniStarterConfig
    config = function(_, opts)
      require("mini.starter").setup(opts)

      -- mini paints each item's shortest unique prefix with `WarningMsg`. Across
      -- file paths that prefix is the shared directory part, so a slice of every
      -- path would wear the accent colour in a different place; keep the prefix
      -- in the item's own colour. Query feedback still comes from the items that
      -- stay active (mini dims the rest).
      local group = vim.api.nvim_create_augroup("starter_highlight", { clear = true })
      local function links()
        vim.api.nvim_set_hl(0, "MiniStarterItemPrefix", { link = "MiniStarterItem" })
      end
      links()
      vim.api.nvim_create_autocmd("ColorScheme", { group = group, desc = "Item prefix colour", callback = links })
    end,
  },
  {
    "nvim-mini/mini.statusline",
    lazy = false,
    ---@type MiniStatuslineConfig
    opts = {
      use_icons = true,
      content = {
        active = function()
          local statusline = require("mini.statusline")
          local mode, mode_hl = section_mode()
          local git = section_git()
          local lsp = statusline.section_lsp({ trunc_width = 75 })
          local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
          local search = statusline.section_searchcount({ trunc_width = 75, options = { recompute = false } })
          local location = statusline.section_location({ trunc_width = 75 })

          local groups = {
            { hl = mode_hl, strings = { mode } },
            { hl = "MiniStatuslineDevinfo", strings = { git } },
            -- The window header carries the buffer name and its changed-line
            -- counts (pack/winheader), so the statusline only shows state.
            "%<%=",
          }
          vim.list_extend(groups, section_diagnostics())
          vim.list_extend(groups, {
            { hl = "MiniStatuslineDevinfo", strings = { lsp } },
            { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
            { hl = mode_hl, strings = { search, location } },
          })
          return statusline.combine_groups(groups)
        end,
      },
    },
    ---@param opts MiniStatuslineConfig
    config = function(_, opts)
      require("mini.statusline").setup(opts)

      -- Branch fallback cache: invalidate when the working directory or the
      -- checked-out branch changes (gitsigns emits GitSignsUpdate).
      local group = vim.api.nvim_create_augroup("statusline_git_branch", { clear = true })
      vim.api.nvim_create_autocmd("DirChanged", {
        group = group,
        callback = function()
          branch_cache = {}
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "GitSignsUpdate",
        callback = function()
          branch_cache = {}
        end,
      })
    end,
  },
  {
    "nvim-mini/mini.notify",
    event = "VeryLazy",
    opts = {},
  },
  {
    "nvim-mini/mini.clue",
    event = "VeryLazy",
    config = function()
      local clue = require("mini.clue")
      ---@type MiniClueConfig
      local opts = {
        triggers = {
          { mode = "n", keys = "<Leader>" },
          { mode = "n", keys = "<LocalLeader>" },
          { mode = "n", keys = "g" },
          { mode = "x", keys = "g" },
          { mode = "n", keys = "z" },
          { mode = "n", keys = "[" },
          { mode = "n", keys = "]" },
          { mode = "n", keys = "<C-w>" },
          { mode = "x", keys = "<Leader>" },
        },
        window = { delay = 300 },
        clues = {
          clue.gen_clues.builtin_completion(),
          -- `gs` is mini.surround's prefix here, not the builtin `gs` (sleep),
          -- so drop that generated clue; the group below replaces it.
          vim.tbl_filter(function(entry)
            return not (entry.mode == "n" and entry.keys == "gs")
          end, clue.gen_clues.g()),
          clue.gen_clues.marks(),
          clue.gen_clues.registers(),
          clue.gen_clues.square_brackets(),
          -- Groups for the mappings these specs declare. `gs` needs both modes:
          -- visual only has add/find, not delete/replace/highlight.
          { mode = "n", keys = "gs", desc = "+surround" },
          { mode = "x", keys = "gs", desc = "+surround" },
          { mode = "n", keys = "<Leader>f", desc = "+find" },
          { mode = "n", keys = "<Leader>g", desc = "+git" },
          { mode = "n", keys = "<Leader>b", desc = "+buffer" },
          { mode = "n", keys = "<Leader>c", desc = "+code" },
          { mode = "n", keys = "<Leader>d", desc = "+database" },
          { mode = "n", keys = "<Leader>o", desc = "+opencode" },
          { mode = "n", keys = "<LocalLeader>", desc = "+splits" },
        },
      }
      clue.setup(opts)
    end,
  },
  {
    -- Viewport jumps only; `j`/`k` never animate.
    "nvim-mini/mini.animate",
    event = "VeryLazy",
    config = function()
      local animate = require("mini.animate")
      ---@type MiniAnimateConfig
      local opts = {
        cursor = { enable = false },
        -- Keep scroll animation for <C-d>/<C-u>; mouse wheel is handled
        -- separately in keymaps.lua (animation disabled there).
        scroll = {
          enable = true,
          timing = function(_, n)
            return math.min(6, 120 / n)
          end,
        },
        resize = {
          enable = true,
          timing = animate.gen_timing.linear({ duration = 60, unit = "total" }),
        },
        open = { enable = false },
        close = { enable = false },
      }
      animate.setup(opts)
    end,
  },
  {
    -- The token keeps its highlighting; the colour becomes an EOL block.
    -- Tailwind classes belong to the Tailwind server (see lsp.lua).
    "nvim-mini/mini.hipatterns",
    event = { "BufReadPost", "BufNewFile" },
    ---@return MiniHipatternsConfig
    opts = function()
      local hipatterns = require("mini.hipatterns")

      -- Empty group: the extmark omits `hl_group`, so only virtual text paints.
      local swatch_group = "HipatternsSwatch"
      vim.api.nvim_set_hl(0, swatch_group, {})

      local function swatch(hex_of)
        return function(_, match)
          local hex = hex_of(match)
          local hl_group = hex and hipatterns.compute_hex_color_group(hex, "fg")
          if hl_group == nil then
            return {}
          end
          return { virt_text = { { constants.swatch, hl_group } }, virt_text_pos = "eol", priority = 2000 }
        end
      end

      local normalise_hex = require("util.shared").normalise_hex

      local hex_color = hipatterns.gen_highlighter.hex_color()
      hex_color.group = function()
        return swatch_group
      end
      hex_color.extmark_opts = swatch(normalise_hex)

      -- Classes the Tailwind server cannot resolve (v4 tokens kept in
      -- `:root`); see util/tailwind.lua.
      local tailwind = require("util.tailwind")

      -- The resolver reads CSS asynchronously, so the first paint can miss
      -- design-token swatches; repaint when a palette arrives.
      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("tailwind_colors_repaint", { clear = true }),
        pattern = "TailwindColorsReady",
        callback = function()
          for _, buf in ipairs(hipatterns.get_enabled_buffers()) do
            pcall(hipatterns.update, buf)
          end
        end,
      })

      local web_filetypes = require("util.shared").web_filetypes

      return {
        highlighters = {
          hex_color = hex_color,
          shorthand = {
            pattern = "#%x%x%x%f[^%x]",
            group = function()
              return swatch_group
            end,
            extmark_opts = swatch(normalise_hex),
          },
          theme_class = {
            pattern = function(buf_id)
              if not vim.tbl_contains(web_filetypes, vim.bo[buf_id].filetype) then
                return nil
              end
              return "%f[%w:!_-]()[%w:!_-]+()"
            end,
            group = function(buf_id, match, data)
              local hex = tailwind.lookup(buf_id, match)
              if hex == nil then
                return nil
              end
              data.hex = hex
              return swatch_group
            end,
            extmark_opts = function(_, _, data)
              return {
                virt_text = { { constants.swatch, hipatterns.compute_hex_color_group(data.hex, "fg") } },
                virt_text_pos = "eol",
                priority = 2000,
              }
            end,
          },
        },
      }
    end,
  },
  {
    -- Local plugin (pack/winheader): the header above every file window. Loaded
    -- on the first buffer rather than at startup; it renders its own windows
    -- during setup, so none is missed.
    "winheader.nvim",
    dir = vim.fn.stdpath("config") .. "/pack/winheader",
    main = "winheader",
    event = "BufWinEnter",
    ---@type winheader.Opts
    opts = {},
  },
}
