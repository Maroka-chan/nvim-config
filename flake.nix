{
  description = "Neovim Configuration Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ { self, nixpkgs, flake-parts, home-manager }:
  flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];

    perSystem = { config, self', inputs', system, ... }: let
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.default = pkgs.callPackage ./neovim.nix {};
    };
  };
}
