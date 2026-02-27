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
vim.o.updatetime         = 250
vim.o.splitright         = true

vim.cmd(":hi statusline guibg=NONE")

require "guess-indent".setup({})
require "fidget".setup({})
require "lualine".setup({})
require "luasnip.loaders.from_vscode".lazy_load()

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
        },
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
                                vim.lsp.buf.format { async = false }
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
                "exclude"
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
        }, { "nix", "run", "nixpkgs#alejandra" })
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

vim.lsp.enable('basedpyright')
vim.lsp.config('basedpyright', {
        cmd = cmd_with_fallback(
                "basedpyright-langserver",
                "nixpkgs#basedpyright",
                { "--stdio" }
        )
})

vim.lsp.enable('ruff')
vim.lsp.config('ruff', {
        cmd = cmd_with_fallback(
                "ruff",
                "nixpkgs#ruff",
                { "server" }
        )
})

vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
        callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client == nil then
                        return
                end
                if client.name == 'ruff' then
                        -- Disable hover in favor of Pyright
                        client.server_capabilities.hoverProvider = false
                end
        end,
        desc = 'LSP: Disable hover capability from Ruff',
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

--  ▄▀▄ █
--  █▀█ █

local copilot = require("copilot")
copilot.setup({
        panel = { enabled = false },
        suggestion = {
                auto_trigger = false, -- Suggest as we start typing
                keymap = {
                        accept_line = "<C-l>",
                        accept = "<C-CR>",
                        prev = "<C-,>",
                        next = "<C-.>",
                },
        },
})

vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuOpen",
        callback = function()
                vim.b.copilot_suggestion_hidden = true
        end,
})

vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuClose",
        callback = function()
                vim.b.copilot_suggestion_hidden = false
        end,
})

local codecompanion = require("codecompanion")
codecompanion.setup({
        ignore_warnings = true,
        strategies = {
                chat = {
                        adapter = {
                                name = "copilot",
                                model = "claude-sonnet-4",
                        },
                        keymaps = {
                                send = {
                                        modes = { i = "<CR>" },
                                        opts = {},
                                },
                                close = {
                                        modes = { n = "<Esc>" },
                                        opts = {},
                                },
                                -- Add further custom keymaps here
                        },
                },
                inline = {
                        adapter = {
                                name = "copilot",
                                model = "claude-sonnet-4",
                        },
                        keymaps = {
                                accept_change = {
                                        modes = { n = "<leader>aa" },
                                        description = "Accept the suggested change",
                                },
                                reject_change = {
                                        modes = { n = "<leader>ar" },
                                        opts = { nowait = true },
                                        description = "Reject the suggested change",
                                },
                        },
                },
        },
        display = {
                chat = {
                        window = {
                                width = 0.3,
                        },
                },
        },
})

require("render-markdown").setup({
        file_types = { "markdown", "codecompanion" },
        render_modes = true,     -- Render in ALL modes
        sign = {
                enabled = false, -- Turn off in the status column
        },
        latex = { enabled = false },
        overrides = {
                filetype = {
                        codecompanion = {
                                html = {
                                        tag = {
                                                buf = { icon = " ", highlight = "CodeCompanionChatIcon" },
                                                file = { icon = " ", highlight = "CodeCompanionChatIcon" },
                                                group = { icon = " ", highlight = "CodeCompanionChatIcon" },
                                                help = { icon = "󰘥 ", highlight = "CodeCompanionChatIcon" },
                                                image = { icon = " ", highlight = "CodeCompanionChatIcon" },
                                                symbols = { icon = " ", highlight = "CodeCompanionChatIcon" },
                                                tool = { icon = "󰯠 ", highlight = "CodeCompanionChatIcon" },
                                                url = { icon = "󰌹 ", highlight = "CodeCompanionChatIcon" },
                                        },
                                },
                        },
                },
        },
})

local diff = require("mini.diff")
diff.setup({
        source = diff.gen_source.none(),
})

require("img-clip").setup({
        filetypes = {
                codecompanion = {
                        prompt_for_file_name = false,
                        template = "[Image]($FILE_PATH)",
                        use_absolute_path = true,
                },
        },
})



--  █▄▀ ██▀ ▀▄▀ █▄ ▄█ ▄▀▄ █▀▄ ▄▀▀
--  █ █ █▄▄  █  █ ▀ █ █▀█ █▀  ▄██

local wk = require("which-key")
wk.setup({ preset = "helix" })
wk.add({
        { "<leader>e",  function() snacks.explorer.open({ auto_close = true }) end,         desc = "Explore files" },
        { "<leader>lg", function() snacks.lazygit() end,                                    desc = "Lazygit" },
        { "<leader>f",  function() picker.files(picker_config) end,                         desc = "Find files" },
        { "<leader>g",  function() picker.grep(picker_config) end,                          desc = "Live Grep" },
        { "<leader>b",  function() picker.buffers(picker_config) end,                       desc = "List Buffers" },
        { "<leader>p",  function() picker.projects(picker_config) end,                      desc = "List Projects" },
        { "<leader>t",  ToggleTerm,                                                         desc = "Open terminal" },
        { "<leader>ac", function() codecompanion.chat() end,                                desc = "Open AI Chat" },
        { "<leader>as", function() require("copilot.suggestion").toggle_auto_trigger() end, desc = "Toggle Copilot Suggestions" },
        { "gd",         vim.lsp.buf.definition,                                             desc = "Goto definition" },
        { "dn",         function() vim.diagnostic.jump({ count = 1, float = true }) end,    desc = "Goto next diagnostics" },
        { "dp",         function() vim.diagnostic.jump({ count = -1, float = true }) end,   desc = "Goto previous diagnostics" },
        { "sr",         function() picker.lsp_references(picker_config) end,                desc = "Show references" },
})
vim.keymap.set('t', '<Esc>', ToggleTerm)


-- Show diagnostics on hover
vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
                vim.diagnostic.open_float(nil, {
                        focusable = false,
                        close_events = { "CursorMoved", "BufLeave", "InsertEnter" },
                        border = "rounded",
                        scope = "cursor",
                })
        end,
})
