{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    lib = import ./lib nixpkgs.lib;

    flakeModule = import ./flake-module.nix self;
  };
}
