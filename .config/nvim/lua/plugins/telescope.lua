return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-file-browser.nvim",
  },
  ---@module "telescope"
  opts = {
    defaults = {
      dynamic_preview_title = true,
      path_display = { "smart" },
      prompt_prefix = "  ",
      selection_caret = " ",
      cache_picker = true,
      file_ignore_patterns = {
        "node_modules",
        ".git/",
        ".next/",
        "dist/",
        "build/",
        "bin/",
      },
      preview = {
        treesitter = true,
      },
      layout_config = {
        horizontal = {
          height = 0.8,
          width = 0.8,
          preview_width = 0.6,
        },
        vertical = {
          height = 0.8,
          width = 0.95,
          preview_height = 0.7,
        },
      },
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
        },
      },
    },
    -- builtin pickers
    pickers = {
      find_files = {
        find_command = { "fd" },
        hidden = false,
        no_ignore = false,
        follow = true,
      },
      git_status = {
        layout_strategy = "vertical",
      },
      git_commits = {
        layout_strategy = "vertical",
      },
    },
    -- extensions
    extensions = {
      file_browser = {
        initial_mode = "normal",
        cwd_to_path = true,
        hidden = true,
        no_ignore = true,
        respect_gitignore = false,
        select_buffer = true,
        use_fd = true,
        file_ignore_patterns = {},
        path = "%:p:h",
        dir_icon = "",
        grouped = true,
        prompt_path = true,
      },
    },
  },
  config = function(_, opts)
    local ok_telescope, telescope = pcall(require, "telescope")
    if not ok_telescope then
      print("error loading telescope")
      return
    end
    telescope.setup(opts)
  end,
  keys = function()
    -- pickers
    local ok_builtin, builtin = pcall(require, "telescope.builtin")
    local ok_previewers, previewers = pcall(require, "telescope.previewers")

    local M = {}

    if not ok_builtin or not ok_previewers then
      print("error loading telescope")
      return
    end

    local git_command = function(entry)
      return {
        "git",
        "-c",
        "core.pager=delta",
        "-c",
        "delta.side-by-side=true",
        "diff",
        entry,
      }
    end

    local delta = previewers.new_termopen_previewer({
      get_command = function(entry)
        -- this is for status
        -- You can get the AM things in entry.status. So we are displaying file if entry.status == '??' or 'A '
        -- just do an if and return a different command
        if entry.status == "??" or "A " then
          return git_command(entry.value)
        end

        -- this command is for git_commits
        return git_command(entry.value .. "^!")
      end,
    })

    M.my_git_commits = function(opts)
      opts = opts or {}
      opts.previewer = delta

      builtin.git_commits(opts)
    end

    M.my_git_status = function(opts)
      opts = opts or {}
      opts.previewer = delta

      builtin.git_status(opts)
    end

    return {
      {
        "<leader>ff",
        function()
          builtin.find_files()
        end,
        desc = "Search files",
      },
      {
        "<leader>fg",
        function()
          builtin.live_grep()
        end,
        desc = "Search keyword",
      },
      {
        "<leader>n",
        function()
          require("telescope").extensions.file_browser.file_browser()
        end,
        desc = "Open file browser",
      },
      {
        "<leader>fd",
        function()
          require("telescope.builtin").diagnostics()
        end,
        desc = "Show diagnostics",
      },
      -- git
      --
      {
        "<leader>gc",
        function()
          M.my_git_commits()
        end,
        desc = "Show git commits",
      },
      {
        "<leader>gs",
        function()
          M.my_git_status()
        end,
        desc = "Show git status",
      },
      {
        "<leader>gb",
        function()
          require("telescope.builtin").git_branches()
        end,
        desc = "Show git branches",
      },
    }
  end,
}
