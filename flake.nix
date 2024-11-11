{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {flake-parts, ...}:
    with inputs;
      flake-parts.lib.mkFlake {inherit inputs;} {
        imports = [inputs.treefmt-nix.flakeModule];

        systems = ["x86_64-linux"];
        flake = {
          lib = import ./lib nixpkgs.lib;

          flakeModule = import ./flake-module.nix self;
        };
        perSystem = {
          pkgs,
          config,
          ...
        }: {
          treefmt = {
            projectRootFile = ".git/config";
            programs.alejandra.enable = true;
          };

          packages.docs = (self.lib.mkDocs {inherit pkgs;}).optionsAsciiDoc;

          devShells.default =
            pkgs.mkShell {buildInputs = [config.treefmt.build.wrapper];};

          formatter = config.treefmt.build.wrapper;
        };
      };
}
