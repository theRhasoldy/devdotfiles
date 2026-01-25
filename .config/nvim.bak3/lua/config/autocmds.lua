local utils = require("config.utils")

-- Format Options
local FormatOptions = utils.create_group("FormatOptions", { clear = true })
utils.create_autocmd("BufEnter", {
  group = FormatOptions,
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})
