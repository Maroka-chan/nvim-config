vim.o.number         = true
vim.o.relativenumber = true
vim.o.wrap           = true
vim.o.swapfile       = false
vim.o.tabstop        = 4
vim.o.expandtab      = true
vim.o.signcolumn     = 'yes'
vim.o.clipboard      = 'unnamedplus'
vim.o.winborder      = "rounded"
vim.g.mapleader      = " "
vim.o.termguicolors  = true -- Enable 24-bit color

vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")

require "lualine".setup({})
require "luasnip.loaders.from_vscode".lazy_load()
local yazi = require "yazi"
yazi.setup({ open_for_directories = true })
local snacks = require "snacks"
local picker_config = { win = { input = { keys = { ["<Esc>"] = { "cancel", mode = "i" }, } } } }
vim.keymap.set('n', '<leader>f', function() snacks.picker.files(picker_config) end)
vim.keymap.set('n', '<leader>g', function() snacks.picker.grep(picker_config) end)
vim.keymap.set('n', '<leader>e', yazi.yazi)
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

-- Autocomplete
local blink = require "blink.cmp"
blink.setup({
        completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 500, },
                accept = { auto_brackets = { enabled = false }, },
                list = { selection = { preselect = false } },
                ghost_text = { enabled = true, show_without_selection = true },
        },
        signature = { enabled = true },
        fuzzy = { implementation = "prefer_rust_with_warning" },
        keymap = {
                preset = 'default',
                ['<Tab>'] = { 'select_and_accept', 'fallback' },
                ['<CR>'] = { 'accept', 'fallback' },
        },
        snippets = { preset = 'luasnip' },
})

-- LSP
vim.lsp.enable({ 'lua_ls', 'rust_analyzer', 'nixd' })
vim.lsp.config('lua_ls', {
        capabilities = blink.get_lsp_capabilities(),
        settings = {
                Lua = {
                        runtime = {
                                -- Tell the language server which version of Lua you're using
                                -- (most likely LuaJIT in the case of Neovim)
                                version = 'LuaJIT',
                        },
                        diagnostics = {
                                -- Get the language server to recognize the `vim` global
                                globals = {
                                        'vim',
                                        'require'
                                },
                        },
                        workspace = {
                                -- Make the server aware of Neovim runtime files
                                library = vim.api.nvim_get_runtime_file("", true),
                        },
                        -- Do not send telemetry data containing a randomized but unique identifier
                        telemetry = {
                                enable = false,
                        },
                },
        },
})
vim.lsp.config('rust_analyzer', {
        capabilities = blink.get_lsp_capabilities(),
        -- Server-specific settings. See `:help lsp-quickstart`
        settings = {
                ['rust-analyzer'] = {},
        },
})
vim.lsp.config('nixd', { capabilities = blink.get_lsp_capabilities(), })

-- Autopairs
require("ultimate-autopair").setup({
        fastwarp = {
                map = '<C-S-.>',
                rmap = '<C-S-,>',
                cmap = '<C-S-.>',
                rcmap = '<C-S-,>',
        },
        close = {
                map = '<C-S-0>',
                cmap = '<C-S-0>',
        },
})

-- Terminal
local term_buf = nil
local term_win_id = nil
function ToggleTerm()
        if term_win_id then
                vim.fn.win_execute(term_win_id, "hide")
                term_win_id = nil
        elseif term_buf and vim.fn.bufexists(term_buf) == 1 then
                vim.cmd("sbuffer " .. term_buf .. "| wincmd J")
                term_win_id = vim.fn.win_getid()
                vim.cmd("startinsert")
        else
                vim.cmd("split | wincmd J | terminal")
                term_win_id = vim.fn.win_getid()
                term_buf = vim.fn.bufnr('%')
                vim.cmd("startinsert")
        end
end

vim.keymap.set('n', '<leader>t', ToggleTerm)
vim.keymap.set('t', '<Esc>', ToggleTerm)
