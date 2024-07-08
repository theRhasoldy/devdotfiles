-- Implement delta as previewer for diffs
local ok_builtin, builtin = pcall(require, "telescope.builtin")
local ok_previewers, previewers = pcall(require, "telescope.previewers")

local E = {}

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

E.my_git_commits = function(opts)
  opts = opts or {}
  opts.previewer = delta

  builtin.git_commits(opts)
end

E.my_git_status = function(opts)
  opts = opts or {}
  opts.previewer = delta

  builtin.git_status(opts)
end

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  cmd = "Telescope",
  opts = {
    defaults = {
      preview = {
        treesitter = true,
      },
    },
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
  },
  config = function(_, opts)
    require("telescope").setup(opts)
    require("telescope").load_extension("fzf")
  end,
  keys = {
    -- pickers
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files()
      end,
      desc = "Search files",
    },
    {
      "<leader>fg",
      function()
        require("telescope.builtin").live_grep()
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
        E.my_git_commits()
      end,
      desc = "Show git commits",
    },
    {
      "<leader>gs",
      function()
        E.my_git_status()
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
  },
}
