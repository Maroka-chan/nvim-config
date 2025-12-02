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
              ];
            }
          )
        );
    in
    rec {
      packages = forAllSystems (pkgs: {
        default = pkgs.callPackage ./neovim.nix { };
      });

      nixosModules = rec {
        custom-neovim = import ./module.nix packages;
        default = custom-neovim;
      };
    };
}
