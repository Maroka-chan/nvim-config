{
  description = "Neovim Configuration Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs =
    { nixpkgs, neovim-nightly, ... }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems =
        function:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          function (
            import nixpkgs {
              inherit system;
              overlays = [
                neovim-nightly.overlays.default
                # Temporary overlay until https://github.com/NixOS/nixpkgs/pull/464616
                # gets into unstable
                (_: prev: {
                  vimPlugins = prev.vimPlugins // {
                    lualine-nvim = prev.neovimUtils.buildNeovimPlugin {
                      luaAttr = prev.luaPackages.lualine-nvim.overrideAttrs {
                        knownRockspec =
                          (prev.fetchurl {
                            url = "mirror://luarocks/lualine.nvim-scm-1.rockspec";
                            sha256 = "01cqa4nvpq0z4230szwbcwqb0kd8cz2dycrd764r0z5c6vivgfzs";
                          }).outPath;
                        src = prev.fetchFromGitHub {
                          owner = "nvim-lualine";
                          repo = "lualine.nvim";
                          rev = "47f91c416daef12db467145e16bed5bbfe00add8";
                          hash = "sha256-OpLZH+sL5cj2rcP5/T+jDOnuxd1QWLHCt2RzloffZOA=";
                        };
                      };
                    };
                  };
                })
              ];
            }
          )
        );
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.callPackage ./neovim.nix { };
      });
    };
}
