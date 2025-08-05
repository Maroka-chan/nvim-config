vim.o.number         = true
vim.o.relativenumber = true
vim.o.wrap           = false
vim.o.swapfile       = false
vim.o.tabstop        = 4
vim.o.expandtab      = true
vim.o.signcolumn     = 'yes'
vim.o.clipboard      = 'unnamedplus'
vim.o.winborder      = "rounded"
vim.g.mapleader      = " "
vim.o.termguicolors = true -- Enable 24-bit color

vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")

require "oil".setup() -- File Explorer
require "mini.pick".setup() -- Search files and live grep
vim.keymap.set('n', '<leader>f', ":Pick files<CR>")
vim.keymap.set('n', '<leader>g', ":Pick grep_live<CR>")
vim.keymap.set('n', '<leader>h', ":Pick help<CR>")
vim.keymap.set('n', '<leader>e', ":Oil<CR>")
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

-- Autocomplete
local cmp = require 'cmp';
cmp.setup({
        snippet = {
                -- REQUIRED - you must specify a snippet engine
                expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                        vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
                end,
        },
        window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = false }),
                ['<Tab>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
        }, {
                { name = 'buffer' },
        }),
        experimental = {
                ghost_text = true,
        },
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
                { name = 'buffer' }
        }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
                { name = 'path' }
        }, {
                { name = 'cmdline' }
        }),
        matching = { disallow_symbol_nonprefix_matching = false }
})

-- LSP
local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.enable({ 'lua_ls', 'rust_analyzer' })
vim.lsp.config('lua_ls', {
        capabilities = capabilities,
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
        capabilities = capabilities,
        -- Server-specific settings. See `:help lsp-quickstart`
        settings = {
                ['rust-analyzer'] = {},
        },
})

-- Autopairs
require("ultimate-autopair").setup({
  fastwarp = {
    map = '<C-S-.>',
    rmap = '<C-S-,>',
    cmap = '<C-S-.>',
    rcmap = '<C-S-,>',
  },
  close = {
    map='<C-S-0>',
    cmap='<C-S-0>',
  },
})

-- Terminal
local term_buf = nil
local term_win_id = nil
function ToggleTerm()
        if term_win_id then
                vim.cmd("hide")
                term_win_id = nil
        elseif term_buf then
                vim.cmd("sbuffer " .. term_buf .. "| wincmd J")
                term_win_id = vim.fn.win_getid()
        else
                vim.cmd("split | wincmd J | terminal")
                term_win_id = vim.fn.win_getid()
                term_buf = vim.fn.bufnr('%')
        end
        vim.cmd("startinsert")
end
vim.keymap.set({ 'n', 't' }, '<leader>t', ToggleTerm)
