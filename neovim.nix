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
}:
let
  packageName = "monica";

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
    mini-diff
    img-clip-nvim
    render-markdown-nvim
    codecompanion-nvim
    markdown-preview-nvim
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

    ln -vsfT ${./config/nvim} $out/pack/${packageName}/start/${packageName}-nvim

    ${lib.concatMapStringsSep "\n" (
      plugin: "ln -vsfT ${plugin} $out/pack/${packageName}/start/${lib.getName plugin}"
    ) startPluginsWithDeps}
  '';

  runtimePath = lib.makeBinPath (
    with pkgs;
    [
      fd
      ripgrep
      curl
      coreutils
      nodejs
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
      --add-flags '--cmd' \
      --add-flags "'set packpath^=${packpath} | set runtimepath^=${packpath}'" \
      --add-flags '--cmd' \
      --add-flags "'colorscheme ${colorschemeName}'" \
      --set-default NVIM_APPNAME nvim-custom
  '';

  passthru = {
    inherit packpath;
  };
}
