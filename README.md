# Personal Neovim Configuration

## Try Out

```bash
nix run github:Maroka-chan/nvim-config
```

## Install

```bash
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim.url = "github:Maroka-chan/nvim-config";
    neovim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, neovim, ... }:
  {
    # Change hostname, system, etc. as needed.
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        neovim.packages.${system}.default
      ];
    };
  };
}
```

