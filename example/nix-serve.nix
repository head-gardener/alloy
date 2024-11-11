{lib, ...}: {
  options = {
    services.nix-serve.pubkey = lib.mkOption {type = lib.types.str;};
  };

  config = {
    services.nix-serve = {
      pubkey = "server:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

      enable = true;
      openFirewall = true;
    };
  };
}
