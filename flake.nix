{
  description = "Neovim Configuration Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs @ { nixpkgs, flake-parts, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];

    perSystem = { system, ... }: let
      pkgs = import nixpkgs { inherit system; overlays = [ inputs.neovim-nightly-overlay.overlays.default ]; };
    in {
      packages.default = pkgs.callPackage ./neovim.nix {};
      packages.old = pkgs.callPackage ./neovim_old.nix {};
    };
  };
}
