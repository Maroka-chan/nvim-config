local blink_cmp = require('blink-cmp')

blink_cmp.setup({
  keymap = {
    preset = 'default',

    ['<Tab>'] = { 'select_and_accept', 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },
  },
  appearance = {
    -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = 'mono',
  },
  -- (Default) Only show the documentation popup when manually triggered
  completion = {
    documentation = { auto_show = false },
    ghost_text = {
      enabled = true,
      show_without_selection = true
    },
    list = { selection = { preselect = false } },
    menu = {
      draw = { columns = { { "label", "label_description", gap = 1 }, { "kind_icon", gap = 1, "kind" } } },
      border = 'rounded'
    }
  },

  snippets = { preset = 'luasnip' },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" }
})

require('luasnip.loaders.from_vscode').lazy_load()

