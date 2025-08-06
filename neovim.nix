{
  symlinkJoin,
  neovim-unwrapped,
  makeWrapper,
  runCommandLocal,
  vimPlugins,
  pkgs,
  lib,
}:
let
  packageName = "mypackage";

  vague = pkgs.vimUtils.buildVimPlugin {
    name = "vague.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "vague2k";
      repo = "vague.nvim";
      rev = "v1.4.1";
      hash = "sha256-isROQFePz8ofJg0qa3Avbwh4Ml4p9Ii2d+VAAkbeGO8=";
    };
  };

  startPlugins = with vimPlugins; [
    vague
    nvim-lspconfig
    mini-pick
    snacks-nvim
    lualine-nvim
    ultimate-autopair-nvim
    nvim-web-devicons
    yazi-nvim
    luasnip
    friendly-snippets
    blink-cmp
    fidget-nvim
  ];

  foldPlugins = builtins.foldl' (
    acc: next:
    acc
    ++ [
      next
    ]
    ++ (foldPlugins (next.dependencies or [ ]))
  ) [ ];

  startPluginsWithDeps = lib.unique (foldPlugins startPlugins);

  packpath = runCommandLocal "packpath" { } ''
    mkdir -p $out/pack/${packageName}/{start,opt}

    ln -vsfT ${./config/nvim} $out/pack/${packageName}/start/myplugin

    ${lib.concatMapStringsSep "\n" (
      plugin: "ln -vsfT ${plugin} $out/pack/${packageName}/start/${lib.getName plugin}"
    ) startPluginsWithDeps}
  '';

  runtimePath = lib.makeBinPath (
    with pkgs;
    [
      lua-language-server
      rust-analyzer
      nixd
      nixfmt
      yazi
    ]
  );
in
symlinkJoin {
  name = "nvim";
  paths = [ neovim-unwrapped ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/nvim \
      --suffix PATH : ${runtimePath} \
      --set YAZI_CONFIG_HOME ${./config/yazi} \
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
