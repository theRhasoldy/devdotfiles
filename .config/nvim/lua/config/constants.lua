return {
  border = "single",

  -- Swatch for mini.hipatterns and the Tailwind LSP painter.
  swatch = "■",

  git_branch = "",

  -- Statusline mode icons, keyed like `vim.fn.mode()` (0x16/0x13 are the
  modes = {
    n = "󰇀",
    i = "󰏫",
    v = "󰒉",
    V = "󰒆",
    ["\22"] = "󰂭",
    s = "󰒉",
    S = "󰒆",
    ["\19"] = "󰂭",
    R = "󰇾",
    c = "󰆍",
    r = "󰋕",
    ["!"] = "󱆃",
    t = "󰞷",
  },

  diagnostics = {
    { glyph = "󰅙", name = "Error" },
    { glyph = "", name = "Warn" },
    { glyph = "", name = "Info" },
    { glyph = "", name = "Hint" },
  },

  -- Share of the editor's columns/rows.
  pick = { width = 0.5, height = 0.4 },
}
