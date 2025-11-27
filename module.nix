packages:
{
  pkgs,
  lib,
  config,
  ...
}:
let
  module_name = "neovim-monica";
  cfg = config.programs."${module_name}";
  inherit (lib)
    mkEnableOption
    mkOverride
    mkOption
    mkIf
    ;
  inherit (lib.types) bool str package;
in
{
  options.programs."${module_name}" = {
    enable = mkEnableOption "Enable Neovim";

    colorschemePackage = mkOption {
      type = package;
      default = pkgs.vimPlugins.vague-nvim;
      description = "Colorscheme plugin package to use.";
    };

    colorschemeName = mkOption {
      type = str;
      default = "vague";
      description = "Colorscheme name to load.";
    };

    defaultEditor = mkOption {
      type = bool;
      default = false;
      description = "Sets the EDITOR envvar to neovim.";
    };

    viAlias = mkOption {
      type = bool;
      default = false;
      description = "Add shell alias vi -> nvim.";
    };

    vimAlias = mkOption {
      type = bool;
      default = false;
      description = "Add shell alias vim -> nvim.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (packages.${pkgs.system}.default.override { inherit (cfg) colorschemePackage colorschemeName; })
    ];

    environment.variables.EDITOR = mkIf cfg.defaultEditor (mkOverride 900 "nvim");

    environment.shellAliases = {
      vi = mkIf cfg.viAlias "nvim";
      vim = mkIf cfg.vimAlias "nvim";
    };
  };
}
