-- mini.pick/mini.files instead of telescope and oil/netrw.

-- mini.extra prints the severity initial (E/W/I/H); reuse the gutter glyphs.
local function pick_diagnostics()
  local diagnostics = require("config.constants").diagnostics
  local pick = require("mini.pick")
  local ns = vim.api.nvim_create_namespace("diag_picker_glyphs")

  local show = function(buf_id, items, query)
    pick.default_show(buf_id, items, query)
    vim.api.nvim_buf_clear_namespace(buf_id, ns, 0, -1)
    for i, item in ipairs(items) do
      -- mini.extra falls back to severity 0 for items that carry none.
      local entry = diagnostics[item.severity]
      if entry ~= nil then
        local hl_group = "DiagnosticFloating" .. entry.name
        vim.api.nvim_buf_set_extmark(buf_id, ns, i - 1, 0, {
          end_row = i,
          end_col = 0,
          hl_group = hl_group,
          hl_mode = "blend",
          priority = 199,
        })
        vim.api.nvim_buf_set_extmark(buf_id, ns, i - 1, 0, {
          virt_text = { { entry.glyph, hl_group } },
          virt_text_pos = "overlay",
        })
      end
    end
  end

  require("mini.extra").pickers.diagnostic(nil, { source = { show = show } })
end

-- Side-by-side diffs come from codediff; mini.extra's own choose either dumps a
-- `git show` into a scratch buffer or jumps to the hunk, so the git pickers hand
-- their selection over instead. Deferred because choose runs while the picker
-- float is still the current window.
---@param args string
local function open_codediff(args)
  vim.schedule(function()
    vim.cmd("CodeDiff " .. args)
  end)
end

local function toggle_files()
  local files = require("mini.files")
  if not files.close() then
    files.open(vim.api.nvim_buf_get_name(0), false)
  end
end

---@param item string
local function pick_commit(item)
  local hash = item:match("^(%S+)")
  if hash == nil then
    return
  end
  -- codediff rejects `<rev>^!`, so name both sides explicitly. A root commit has
  -- no parent; the empty tree makes it comparable with nothing.
  local parent = vim.fn.systemlist({ "git", "rev-parse", "--verify", "--quiet", hash .. "^" })[1]
  if parent == nil or parent == "" then
    parent = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"
  end
  open_codediff(parent .. " " .. hash)
end

---@type LazySpec
return {
  {
    "nvim-mini/mini.pick",
    dependencies = { { "nvim-mini/mini.extra", opts = {} } },
    keys = {
      {
        "<leader>ff",
        function()
          local root = require("util.shared").root_of(0, ".git")
          require("mini.pick").builtin.files({ tool = "rg" }, { source = { cwd = root } })
        end,
        desc = "Find files",
      },
      {
        "<leader>f/",
        function()
          local root = require("util.shared").root_of(0, ".git")
          require("mini.pick").builtin.grep_live({ tool = "rg" }, { source = { cwd = root } })
        end,
        desc = "Grep live",
      },
      {
        "<leader>fb",
        function()
          require("mini.pick").builtin.buffers()
        end,
        desc = "Find buffers",
      },
      {
        "<leader>fh",
        function()
          require("mini.pick").builtin.help()
        end,
        desc = "Find help",
      },
      {
        "<leader>fr",
        function()
          require("mini.extra").pickers.oldfiles()
        end,
        desc = "Recent files",
      },
      {
        "<leader>fg",
        function()
          require("mini.extra").pickers.git_files()
        end,
        desc = "Git files",
      },
      { "<leader>fd", pick_diagnostics, desc = "Diagnostics" },
      {
        "<leader>gb",
        function()
          require("mini.extra").pickers.git_branches()
        end,
        desc = "Git branches",
      },
      {
        "<leader>gc",
        function()
          require("mini.extra").pickers.git_commits(nil, { source = { choose = pick_commit } })
        end,
        desc = "Git commits",
      },
      {
        "<leader>gC",
        function()
          require("mini.extra").pickers.git_commits(
            { path = vim.api.nvim_buf_get_name(0) },
            { source = { choose = pick_commit } }
          )
        end,
        desc = "Git commits (current file)",
      },
      {
        "<leader>gh",
        function()
          require("mini.extra").pickers.git_hunks()
        end,
        desc = "Git hunks (unstaged)",
      },
      {
        "<leader>gH",
        function()
          require("mini.extra").pickers.git_hunks({ scope = "staged" })
        end,
        desc = "Git hunks (staged)",
      },
      {
        "<leader>gm",
        function()
          -- The picker lists repo-relative paths; codediff resolves pathspecs
          -- against the repo it is pointed at, and the editor's cwd is not
          -- necessarily that repo.
          local root = require("util.shared").root_of(0, ".git")
          require("mini.extra").pickers.git_files({ scope = "modified" }, {
            source = {
              choose = function(item)
                open_codediff("--repo " .. vim.fn.fnameescape(root) .. " -- " .. vim.fn.fnameescape(item))
              end,
            },
          })
        end,
        desc = "Git modified files",
      },
      {
        "<leader>fs",
        function()
          require("mini.extra").pickers.lsp({ scope = "document_symbol" })
        end,
        desc = "Buffer symbols",
      },
      {
        "<leader>fk",
        function()
          require("mini.extra").pickers.keymaps()
        end,
        desc = "Keymaps",
      },
      {
        '<leader>f"',
        function()
          require("mini.extra").pickers.registers()
        end,
        desc = "Registers",
      },
      {
        "<leader>fR",
        function()
          require("mini.pick").builtin.resume()
        end,
        desc = "Resume last picker",
      },
    },
    ---@type MiniPickConfig
    opts = {
      -- <Tab> preview replaces the list in the same window, so the window
      -- size is what makes previews readable.
      window = {
        config = function()
          local pick = require("config.constants").pick
          return {
            width = math.floor(pick.width * vim.o.columns),
            height = math.floor(pick.height * (vim.o.lines - vim.o.cmdheight - 1)),
          }
        end,
      },
    },
  },
  {
    -- Keys-only: the explorer is only reached via <leader>e / `-`.
    "nvim-mini/mini.files",
    keys = {
      { "<leader>e", toggle_files, desc = "File explorer" },
      { "-", toggle_files, desc = "Open parent directory" },
    },
    ---@type MiniFilesConfig
    opts = {
      options = {
        use_as_default_explorer = true,
        -- `d` goes to mini.files' trash rather than deleting.
        permanent_delete = false,
      },
      windows = {
        preview = true,
        max_number = 3,
        width_focus = 45,
        width_nofocus = 20,
        width_preview = 45,
      },
      content = {
        sort = function(entries)
          table.sort(entries, function(a, b)
            if (a.fs_type == "directory") ~= (b.fs_type == "directory") then
              return a.fs_type == "directory"
            end
            return a.name:lower() < b.name:lower()
          end)
          return entries
        end,
      },
    },
    ---@param opts MiniFilesConfig
    config = function(_, opts)
      local files = require("mini.files")
      files.setup(opts)

      local show_dotfiles = true
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        group = vim.api.nvim_create_augroup("mini_files_extras", { clear = true }),
        callback = function(args)
          local buf = args.data.buf_id

          vim.keymap.set("n", "<Esc>", files.close, { buffer = buf, desc = "Close explorer" })
          vim.keymap.set("n", "<CR>", function()
            files.go_in()
          end, { buffer = buf, desc = "Open entry" })

          vim.keymap.set("n", "gy", function()
            local entry = files.get_fs_entry()
            if entry == nil then
              return vim.notify("Cursor is not on a valid entry", vim.log.levels.WARN)
            end
            vim.fn.setreg(vim.v.register, entry.path)
          end, { buffer = buf, desc = "Yank path" })

          vim.keymap.set("n", "gX", function()
            local entry = files.get_fs_entry()
            if entry == nil then
              return vim.notify("Cursor is not on a valid entry", vim.log.levels.WARN)
            end
            vim.ui.open(entry.path)
          end, { buffer = buf, desc = "OS open" })

          vim.keymap.set("n", "g.", function()
            show_dotfiles = not show_dotfiles
            files.refresh({
              content = {
                filter = show_dotfiles and function()
                  return true
                end or function(fs_entry)
                  return not vim.startswith(fs_entry.name, ".")
                end,
              },
            })
          end, { buffer = buf, desc = "Toggle dotfiles" })
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesExplorerOpen",
        group = vim.api.nvim_create_augroup("mini_files_bookmarks", { clear = true }),
        callback = function()
          files.set_bookmark("c", vim.fn.stdpath("config"), { desc = "Config" })
          files.set_bookmark("w", vim.fn.getcwd, { desc = "Working directory" })
          files.set_bookmark("h", "~", { desc = "Home" })
        end,
      })
    end,
  },
}
