local blink_pairs = require('blink-pairs')

local configuration = {
  mappings = {
    enabled = true,
    pairs = {},
  },
  highlights = {
    enabled = true,
    groups = {
      'BlinkPairsOrange',
      'BlinkPairsPurple',
      'BlinkPairsBlue',
    },
  },
  debug = false,
}
blink_pairs.setup(configuration)
