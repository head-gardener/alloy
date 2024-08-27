{ alloy-utils, ... }:
{
  settings = {
    resolve = alloy-utils.fromTable {
      server = "10.0.0.1";
      client = "10.0.0.2";
    };
  };

  modules = {
    nix-serve = ./nix-serve.nix;
    cache = ./cache.nix;
  };

  hosts = mods: with mods; {
    server = [ nix-serve ];
    client = [ cache ];
  };
}
