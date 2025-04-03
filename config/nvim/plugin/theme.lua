require("kanagawa").setup({
  theme = "dragon",
  background = { dark = "dragon" },
  overrides = function(colors)
      return {
        BlinkCmpMenu = { bg = colors.palette.dragonBlack3 },
        BlinkCmpLabelDetail = { bg = colors.palette.dragonBlack3 },
        BlinkCmpMenuSelection = { bg = colors.palette.waveBlue1 },
        FloatBorder = { bg = colors.palette.dragonBlack3 },
      }
  end,
})

vim.cmd("colorscheme kanagawa")
