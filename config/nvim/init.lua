local util               = require("util")
local deep_merge, ntable = util.deep_merge, util.ntable
local cmd_with_fallback  = util.cmd_with_fallback

vim.o.number             = true
vim.o.relativenumber     = true
vim.o.wrap               = true
vim.o.swapfile           = false
vim.o.tabstop            = 4
vim.o.expandtab          = true
vim.o.signcolumn         = 'yes'
vim.o.clipboard          = 'unnamedplus'
vim.o.winborder          = "rounded"
vim.g.mapleader          = " "
vim.o.termguicolors      = true -- Enable 24-bit color
vim.o.colorcolumn        = 80

vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")

require "fidget".setup({})
require "lualine".setup({})
require "luasnip.loaders.from_vscode".lazy_load()
local yazi = require "yazi"
yazi.setup({ open_for_directories = true })


local picker = require "snacks".picker
local picker_config = ntable({ "win", "input", "keys" })
picker_config.win.input.keys = { ["<Esc>"] = { "cancel", mode = "i" }, }

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
                "rust-analyzer",
                "nixpkgs#rust-analyzer"
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
print(vim.inspect(rust_settings))
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
        cmd = { "nix", "run", "nixpkgs#nixd" },
        capabilities = blink.get_lsp_capabilities(),
        settings = nixd_settings
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

vim.keymap.set('n', '<leader>e', yazi.yazi)
vim.keymap.set('n', '<leader>f', function() picker.files(picker_config) end)
vim.keymap.set('n', '<leader>g', function() picker.grep(picker_config) end)
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>t', ToggleTerm)
vim.keymap.set('t', '<Esc>', ToggleTerm)
