local scrollbar = require('scrollbar')
local dragon_colors = require("kanagawa.colors").setup({ theme = 'dragon' })
local colors = dragon_colors.theme

local configuration = {
  handle = {
    color = colors.bg_highlight,
  },
  marks = {
    Search = { color = colors.ui.bg_search },
    Error = { color = colors.diag.error },
    Warn = { color = colors.diag.warning },
    Info = { color = colors.diag.info },
    Hint = { color = colors.diag.hint },
    Misc = { color = colors.ui.special },
  }
}

-- Setup
scrollbar.setup(configuration)
require('scrollbar.handlers.search').setup({ calm_down = true, nearest_only = true })
