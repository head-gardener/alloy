{
  inputs = {
    alloy.url = "../";
  };

  outputs = { alloy, ... }: {

    nixosConfigurations = alloy.lib.apply (import ./alloy_config.nix) {
      server = alloy.inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [];
      };

      client = alloy.inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [];
      };
    };

  };
}
