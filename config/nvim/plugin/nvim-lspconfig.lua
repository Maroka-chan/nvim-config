local lspconfig = require('lspconfig')

-- Language Protocol Server Settings
local lua_settings = {
  Lua = {
    runtime = {
      -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
      version = 'LuaJIT',
    },
    diagnostics = {
      -- Get the language server to recognize the `vim` global
      globals = {'vim'},
    },
    workspace = {
      -- Make the server aware of Neovim runtime files
      library = vim.api.nvim_get_runtime_file("", true),
      checkThirdParty = false,
    },
    telemetry = {
      enable = false,
    },
  },
}

local rust_settings = {
  ["rust-analyzer"] = {
    imports = {
      granularity = {
        group = "module",
      },
      prefix = "self",
    },
    cargo = {
      buildScripts = {
        enable = true,
      },
      features = "all",
    },
    procMacro = {
      enable = true
    },
    cachePriming = {
      enable = false
    }
  }
}

-- Language Server Protocols to Enable
local servers = {
  lua_ls = lua_settings,
  bashls = {},
  csharp_ls = {},
  dockerls = {},
  docker_compose_language_service = {},
  gopls = {},
  pyright = {},
  texlab = {},
  clangd = {},
  rust_analyzer = rust_settings,
  nil_ls = {},
}

for server, config in pairs(servers) do
  config.capabilities =
    require('blink.cmp').get_lsp_capabilities(config.capabilities)

  lspconfig[server].setup(config)
end

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function()
    local bufmap = function(mode, lhs, rhs)
      local opts = {buffer = true}
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    bufmap('n',         'K',      vim.lsp.buf.hover)
    bufmap('n',         'gd',     vim.lsp.buf.definition)
    bufmap('n',         'gD',     vim.lsp.buf.declaration)
    bufmap('n',         'gi',     vim.lsp.buf.implementation)
    bufmap('n',         'go',     vim.lsp.buf.type_definition)
    bufmap('n',         'gr',     vim.lsp.buf.references)
    bufmap('n',         'gs',     vim.lsp.buf.signature_help)
    bufmap('n',         '<F2>',   vim.lsp.buf.rename)
    bufmap('n',         '<F3>',   function() vim.lsp.buf.format({ async = true }) end)
    bufmap({'v', 'n'},  '<M-CR>', vim.lsp.buf.code_action)

    bufmap('n',         'gl',     vim.diagnostic.open_float)
    bufmap('n',         '[d',     function() vim.diagnostic.jump({ count = -1, float = true }) end)
    bufmap('n',         ']d',     function() vim.diagnostic.jump({ count = 1, float = true }) end)
  end
})
