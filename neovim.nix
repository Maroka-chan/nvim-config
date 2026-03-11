{
  symlinkJoin,
  neovim-unwrapped,
  makeWrapper,
  runCommandLocal,
  vimPlugins,
  pkgs,
  lib,
  colorschemePackage ? pkgs.vimPlugins.vague-nvim,
  colorschemeName ? "vague",
}: let
  packageName = "monica";

  agentic-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "agentic.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "carlos-algms";
      repo = "agentic.nvim";
      rev = "main";
      hash = "sha256-/CyZJ3rbwnA6YZtMBFyyK+N6lxXQSszRHkvdS4QeFTI=";
    };
    nvimSkipModules = [
      "agentic.session_manager.test"
      "agentic.acp.slash_commands.test"
      "agentic.session_registry.test"
      "agentic.session_restore.test"
      "agentic.ui.chat_history.test"
      "agentic.ui.chat_widget.test"
      "agentic.ui.code_selection.test"
      "agentic.ui.diagnostics_context.test"
      "agentic.ui.diagnostics_list.test"
      "agentic.ui.diff_preview.test"
      "agentic.ui.diff_split_view.test"
      "agentic.ui.file_list.test"
      "agentic.ui.file_picker.test"
      "agentic.ui.hunk_navigation.test"
      "agentic.ui.message_writer.test"
      "agentic.ui.permission_manager.test"
      "agentic.ui.todo_list.test"
      "agentic.ui.tool_call_diff.test"
      "agentic.ui.widget_layout.test"
      "agentic.utils.buf_helpers.test"
      "agentic.utils.diff_highlighter.test"
      "agentic.utils.object.test"
      "agentic.utils.text_matcher.test"
      "agentic.acp.agent_modes.test"
      "agentic.acp.agent_config_options.test"
      "agentic.acp.agent_models.test"
    ];
  };

  startPlugins = with vimPlugins; [
    colorschemePackage
    nvim-lspconfig
    snacks-nvim
    lualine-nvim
    ultimate-autopair-nvim
    nvim-web-devicons
    luasnip
    friendly-snippets
    blink-cmp
    fidget-nvim
    which-key-nvim
    guess-indent-nvim
    copilot-lua
    markdown-preview-nvim
    agentic-nvim
    render-markdown-nvim
    img-clip-nvim
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

    ln -vsfT ${./config/nvim} $out/pack/${packageName}/start/${packageName}-nvim

    ${lib.concatMapStringsSep "\n" (
        plugin: "ln -vsfT ${plugin} $out/pack/${packageName}/start/${lib.getName plugin}"
      )
      startPluginsWithDeps}
  '';

  runtimePath = lib.makeBinPath (
    with pkgs; [
      fd
      ripgrep
      curl
      coreutils
      nodejs
      lazygit
      opencode
    ]
  );

  opencode_config = pkgs.writers.writeJSON "opencode.json" {
    "$schema" = "https://opencode.ai/config.json";
    permission = {
      "*" = "ask";
      list = "allow";
      glob = "allow";
      grep = "allow";
      read = "allow";
      external_directory = {
        "*" = "deny";
      };
      #bash = "allow";
      #edit = "deny";
    };
    provider.github-copilot = {};
    model = "github-copilot/claude-opus-4.6";
    #small_model = "anthropic/claude-haiku-4-5";
  };
in
  symlinkJoin {
    name = "nvim";
    paths = [neovim-unwrapped];
    nativeBuildInputs = [makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/nvim \
        --suffix PATH : ${runtimePath} \
        --add-flags '--cmd' \
        --add-flags "'set packpath^=${packpath} | set runtimepath^=${packpath}'" \
        --add-flags '--cmd' \
        --add-flags "'colorscheme ${colorschemeName}'" \
        --set-default NVIM_APPNAME nvim-custom \
        --set OPENCODE_CONFIG ${opencode_config}
    '';

    passthru = {
      inherit packpath;
    };
  }
