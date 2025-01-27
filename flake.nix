{
  description = "Neovim Configuration Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ { self, nixpkgs, flake-parts }:
  flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];

    perSystem = { config, self', inputs', system, ... }: let
      pkgs = import nixpkgs { inherit system; };

      plugin_config = pkgs.vimUtils.buildVimPlugin {
        name = "plugin-config";
        src = ./config;
      };

      custom_neovim = pkgs.neovim.override {
        configure = {
          customRC = ''
            luafile ${./config/init.lua}
          '';
          packages.myPlugins = with pkgs.vimPlugins; {
            start = [
              plugin_config

              kanagawa-nvim         # Theme

              nvim-tree-lua         # File Tree
              lualine-nvim          # Status Line
              plenary-nvim          # Lua Helper Functions
              nvim-hlslens          # Match Enhancement
              nvim-scrollbar        # Scrollbar
              nvim-web-devicons     # Icons
              markdown-preview-nvim # Markdown Preview
              toggleterm-nvim


              # Fuzzy Finder
              telescope-nvim
              telescope-fzf-native-nvim

              # LSP
              nvim-lspconfig
              
              # Completion
              nvim-cmp
              cmp-nvim-lsp
              cmp-nvim-lsp-signature-help
              cmp-nvim-lsp-document-symbol
              cmp-path
              cmp-buffer
              cmp-cmdline
              cmp_luasnip
              cmp-rg
              cmp-omni
              nvim-autopairs

              # Snippets
              luasnip
              friendly-snippets

              # Parsing
              nvim-treesitter.withAllGrammars
              nvim-treesitter-context
              nvim-treesitter-refactor
            ];
            opt = [];
          };
        };
      };
    in {
      packages.default = custom_neovim;
    };
  };
}
