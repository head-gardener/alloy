{alloy-utils, ...}: {
  settings = {
    resolve = alloy-utils.fromTable {
      server = "10.0.0.1";
      client = "10.0.0.2";
      laptop = "10.0.0.3";
    };
  };

  modules = {
    nix-serve = ./nix-serve.nix;
    cache = ./cache.nix;
    prometheus-node = ./prometheus-node.nix;
    prometheus-host = ./prometheus-host.nix;
  };

  hosts = mods:
    with mods; {
      server = [prometheus-host nix-serve];
      client = [prometheus-node cache];
      laptop = [prometheus-node cache];
    };
}
