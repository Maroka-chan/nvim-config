local scrollbar = require('scrollbar')
local colors = require('citruszest.palettes.colors')

local configuration = {
  handle = {
    color = colors.bg_highlight,
  },
  marks = {
    Search = { color = colors.orange },
    Error = { color = colors.error },
    Warn = { color = colors.warning },
    Info = { color = colors.info },
    Hint = { color = colors.hint },
    Misc = { color = colors.purple },
  }
}

-- Setup
scrollbar.setup(configuration)
require('scrollbar.handlers.search').setup({ calm_down = true, nearest_only = true })
