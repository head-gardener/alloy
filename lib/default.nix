lib: let
  inherit (lib) attrNames elem filterAttrs mapAttrs fix flip pipe;

  utils = {
    fromTable = table: x: table.${x};
  };

  evalAlloyConfig = cfg: let
    baseModules = [
      ../modules/options.nix
    ];

    userModules =
      if builtins.isList cfg.config
      then cfg.config
      else [cfg.config];

    finalConf = lib.evalModules {
      modules = baseModules ++ userModules;
      specialArgs = {alloy-utils = utils;} // cfg.extraSpecialArgs;
    };
  in
    finalConf;
in {
  inherit utils;

  mkDocs = {pkgs}: let
    eval = evalAlloyConfig [];
    docs = pkgs.nixosOptionsDoc {inherit (eval) options;};
  in
    docs;

  apply = cfg: let
    inherit
      ((evalAlloyConfig cfg).config)
      hosts
      modules
      settings
      ;

    valsToNames = mapAttrs (n: _: n);

    getHosts = module:
      attrNames
      (filterAttrs
        (_: xs: elem module xs)
        (hosts (valsToNames modules)));

    expandHostname = hs: hostname: {
      address = settings.resolve hostname;
      hostname = hostname;
      config = hs.${hostname}.config;
    };

    mkAlloy = hosts: let
      toArg = n: _: let
        allHosts = getHosts n;
        firstHost =
          if allHosts != []
          then (lib.head allHosts)
          else throw "Attempted to get hostname of a module \"${n}\" that is never used";
      in
        (expandHostname hosts firstHost)
        // {
          forEach = f: map (h: f (expandHostname hosts h)) allHosts;
        };

      result = mapAttrs toArg modules;
    in
      result;

    mkHosts = alloy: let
      alloyWithSelf = h: alloy // { self = expandHostname hosts h; };

      extend = h: ms:
        cfg.nixosConfigurations.${h}.extendModules {
          modules = ms;
          specialArgs = { alloy = alloyWithSelf h; } // settings.extraSpecialArgs;
        };
    in
      mapAttrs extend (hosts modules);

    hostsFixedPoint = fix ((flip pipe) [
      mkAlloy
      mkHosts
    ]);
  in
    cfg.nixosConfigurations // hostsFixedPoint;
}
