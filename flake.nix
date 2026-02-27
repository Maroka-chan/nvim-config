{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    supportedSystems = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
    forAllSystems = function:
      nixpkgs.lib.genAttrs supportedSystems (
        system:
          function nixpkgs.legacyPackages.${system}
      );
  in rec {
    packages = forAllSystems (pkgs: {
      default = pkgs.callPackage ./neovim.nix {};
    });

    nixosModules = rec {
      custom-neovim = import ./module.nix packages;
      default = custom-neovim;
    };
  };
}
