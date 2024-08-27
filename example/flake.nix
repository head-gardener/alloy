{
  inputs = {
    alloy.url = "../";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ alloy, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        alloy.flakeModule
      ];

      systems = [ "x86_64-linux" ];

      flake = {
        alloy.config = ./alloy_config.nix;

        alloy.nixosConfigurations = {
          server = alloy.inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ ];
          };

          client = alloy.inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ ];
          };
        };
      };
    };
}
