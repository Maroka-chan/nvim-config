{
  symlinkJoin,
  neovim-unwrapped,
  makeWrapper,
  runCommandLocal,
  vimPlugins,
  lib,
}: let
  packageName = "mypackage";

  startPlugins = with vimPlugins; [
    kanagawa-nvim         # Theme

    nvim-tree-lua         # File Tree
    lualine-nvim          # Status Line
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

  foldPlugins = builtins.foldl' (
    acc: next:
      acc
      ++ [
        next
      ]
      ++ (foldPlugins (next.dependencies or []))
  ) [];

  startPluginsWithDeps = lib.unique (foldPlugins startPlugins);

  packpath = runCommandLocal "packpath" {} ''
    mkdir -p $out/pack/${packageName}/{start,opt}

    ln -vsfT ${./config/nvim} $out/pack/${packageName}/start/myplugin

    ${
      lib.concatMapStringsSep
      "\n"
      (plugin: "ln -vsfT ${plugin} $out/pack/${packageName}/start/${lib.getName plugin}")
      startPluginsWithDeps
    }
  '';
in
  symlinkJoin {
    name = "nvim";
    paths = [neovim-unwrapped];
    nativeBuildInputs = [makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/nvim \
        --add-flags '-u' \
        --add-flags '${./config/nvim/init.lua}' \
        --add-flags '--cmd' \
        --add-flags "'set packpath^=${packpath} | set runtimepath^=${packpath}'" \
        --set-default NVIM_APPNAME nvim-custom
    '';

    passthru = {
      inherit packpath;
    };
  }
