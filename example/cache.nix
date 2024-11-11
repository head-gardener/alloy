{alloy, ...}: let
  inherit (alloy) nix-serve;
in {
  nix = {
    settings = {
      substituters = [
        "http://${nix-serve.address}:${toString nix-serve.config.services.nix-serve.port}"
      ];
      trusted-public-keys = [
        nix-serve.config.services.nix-serve.pubkey
      ];
    };
  };
}
