local util               = require("util")
local deep_merge, ntable = util.deep_merge, util.ntable
local cmd_with_fallback  = util.cmd_with_fallback

vim.o.number             = true
vim.o.relativenumber     = true
vim.o.wrap               = true
vim.o.swapfile           = false
vim.o.expandtab          = true
vim.o.smartindent        = true
vim.o.signcolumn         = 'yes'
vim.o.clipboard          = 'unnamedplus'
vim.o.winborder          = "rounded"
vim.g.mapleader          = " "
vim.o.termguicolors      = true -- Enable 24-bit color
vim.o.colorcolumn        = "80"

vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")

require "guess-indent".setup({})
require "fidget".setup({})
require "lualine".setup({})
require "luasnip.loaders.from_vscode".lazy_load()
local yazi = require "yazi"
yazi.setup({ open_for_directories = true })

vim.api.nvim_set_hl(0, 'SnacksIndent', { fg = "#2b2b2d" })
vim.api.nvim_set_hl(0, 'SnacksIndent1', { fg = "#646469" })

local snacks = require "snacks"
local picker_sources = ntable(
        { "explorer", "layout", "layout", "position" },
        "right"
)
snacks.setup({
        picker = {
                enabled = true,
                sources = picker_sources
        },
        explorer = {
                enabled = true,
                replace_netrw = true
        },
        indent = {
                indent = { hl = "SnacksIndent" },
                scope = {
                        hl = "SnacksIndent1",
                },
                animate = { enabled = false }
        }
})
local picker = snacks.picker
local picker_config = ntable({ "win", "input", "keys" })
picker_config.win.input.keys = { ["<Esc>"] = { "cancel", mode = "i" } }
snacks.indent.enable()


-- ASCII Art: https://texteditor.com/multiline-text-art/


--  ▄▀▀ ▄▀▄ █▄ ▄█ █▀▄ █   ██▀ ▀█▀ █ ▄▀▄ █▄ █
--  ▀▄▄ ▀▄▀ █ ▀ █ █▀  █▄▄ █▄▄  █  █ ▀▄▀ █ ▀█

local blink = require "blink.cmp"
blink.setup({
        completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 500 },
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



--  █   ▄▀▀ █▀▄
--  █▄▄ ▄██ █▀

-- Format on write
vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp", { clear = true }),
        callback = function(args)
                vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = args.buf,
                        callback = function()
                                vim.lsp.buf.format { async = false, id = args.data.client_id }
                        end,
                })
        end
})



vim.lsp.config('*', { capabilities = blink.get_lsp_capabilities() })

vim.lsp.enable('bashls')
vim.lsp.config('bashls', {
        cmd = cmd_with_fallback(
                "bash-language-server",
                "nixpkgs#bash-language-server",
                { "start" }
        )
})

vim.lsp.enable('lua_ls')
local lua_settings = deep_merge(
        ntable({ -- Tell the language server which version of Lua you're using
                "Lua",
                "runtime",
                "version"
        }, 'LuaJIT'),
        ntable({ -- Get the language server to recognize the `vim` global
                "Lua",
                "diagnostics",
                "globals"
        }, { 'vim', 'require' }),
        ntable({ -- Make the server aware of Neovim runtime files
                "Lua",
                "workspace",
                "library"
        }, vim.api.nvim_get_runtime_file("", true)),
        ntable({ -- Do not send telemetry data
                "Lua",
                "telemetry",
                "enable"
        }, false)
)
vim.lsp.config('lua_ls', {
        cmd = cmd_with_fallback(
                "lua-language-server",
                "nixpkgs#lua-language-server"
        ),
        settings = lua_settings
})

vim.lsp.enable('rust_analyzer')
local rust_capabilities = blink.get_lsp_capabilities()
rust_capabilities.workspace = ntable({
        "didChangeWatchedFiles",
        "dynamicRegistration"
}, true)
local rust_excluded_dirs = {
        ".dart_tool",
        ".android",
        ".direnv",
        ".devenv",
        ".idea",
        ".git",
        ".github",
        ".venv",
        "target",
        "build",
        "result",
}
local rust_settings = deep_merge(
        ntable({
                "rust-analyzer",
                "diagnostics",
                "enable"
        }, false),
        ntable({
                "rust-analyzer",
                "files",
                "excludeDirs"
        }, rust_excluded_dirs)
)
vim.lsp.config('rust_analyzer', {
        cmd = cmd_with_fallback(
                "rust-analyzer",
                "nixpkgs#rust-analyzer"
        ),
        capabilities = rust_capabilities,
        -- Server-specific settings. See `:help lsp-quickstart`
        settings = rust_settings
})

vim.lsp.enable('nixd')
local nixd_settings = deep_merge(
        ntable({
                "nixd",
                "nixpkgs",
                "expr"
        }, "import <nixpkgs> {}"),
        ntable({
                "nixd",
                "formatting",
                "command"
        }, { "nix", "run", "nixpkgs#nixfmt" })
)
vim.lsp.config('nixd', {
        cmd = cmd_with_fallback(
                "nixd",
                "nixpkgs#nixd"
        ),
        settings = nixd_settings
})

vim.lsp.enable('dartls')
vim.lsp.config('dartls', {
        cmd = cmd_with_fallback(
                "dart",
                "nixpkgs#dart",
                { "language-server", "--protocol=lsp" }
        )
})



--  ▄▀▄ █ █ ▀█▀ ▄▀▄ █▀▄ ▄▀▄ █ █▀▄ ▄▀▀
--  █▀█ ▀▄█  █  ▀▄▀ █▀  █▀█ █ █▀▄ ▄██

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



--  ▀█▀ ██▀ █▀▄ █▄ ▄█ █ █▄ █ ▄▀▄ █
--   █  █▄▄ █▀▄ █ ▀ █ █ █ ▀█ █▀█ █▄▄

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

--  █▄▀ ██▀ ▀▄▀ █▄ ▄█ ▄▀▄ █▀▄ ▄▀▀
--  █ █ █▄▄  █  █ ▀ █ █▀█ █▀  ▄██

local wk = require("which-key")
wk.setup({ preset = "helix" })
wk.add({
        { "<leader>e", function() snacks.explorer.open({ auto_close = true }) end, desc = "Explore files" },
        { "<leader>f", function() picker.files(picker_config) end,    desc = "Find files" },
        { "<leader>g", function() picker.grep(picker_config) end,     desc = "Live Grep" },
        { "<leader>t", ToggleTerm,                                    desc = "Toggle terminal" },
})
vim.keymap.set('t', '<Esc>', ToggleTerm)
