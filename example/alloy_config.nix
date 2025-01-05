{ alloy-utils, ... }: {
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
    nginx = ./nginx.nix;
    web-app = ./web-app.nix;
  };

  hosts = mods:
    with mods; {
      server = [ nginx prometheus-host nix-serve ];
      client = [ web-app prometheus-node cache ];
      laptop = [ prometheus-node cache ];
    };
}
