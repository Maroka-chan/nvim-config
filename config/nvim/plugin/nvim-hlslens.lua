local hlslens = require('hlslens')


-- Setup
local kmap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

kmap('n', 'n',
    [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
    opts)
kmap('n', 'N',
    [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
    opts)
kmap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], opts)
kmap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], opts)
kmap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], opts)
kmap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], opts)

kmap('n', '<Leader>l', ':noh<CR>', opts)

