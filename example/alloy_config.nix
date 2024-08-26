{
  modules = {
    nix-serve = ./nix-serve.nix;
    cache = ./cache.nix;
  };

  hosts = mods: with mods; {
    server = [ nix-serve ];
    client = [ cache ];
  };
}
