lib: let
  inherit (lib) attrNames elem filterAttrs mapAttrs fix flip pipe nameValuePair;

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
          modules = ms ++ [ ./nixosModule.nix ];
          specialArgs = { alloy = alloyWithSelf h; } // settings.extraSpecialArgs;
        };
    in
      mapAttrs extend (hosts modules);

    addExtensions = hs: let
      extensions = let
        extensionsRotated = mapAttrs (_: v: v.config.alloy.extend) hs;

        rotateConcat = attrs:
          let
            keys = lib.unique (builtins.concatMap
              builtins.attrNames
              (builtins.attrValues attrs));

            result = builtins.listToAttrs (map (key:
              nameValuePair key (
                builtins.concatLists
                  (map (attrSet: attrSet.${key} or [])
                    (builtins.attrValues attrs)))
            ) keys);
          in
            result;
      in rotateConcat extensionsRotated;

      extend = h: val: let
        ms = builtins.concatMap
          (n: extensions.${n} or [])
          (hosts (valsToNames modules)).${h};
      in
        val.extendModules {
          modules = ms;
        };
    in
      mapAttrs extend hs;

    hostsFixedPoint = fix ((flip pipe) [
      mkAlloy
      mkHosts
      addExtensions
    ]);
  in
    cfg.nixosConfigurations // hostsFixedPoint;
}
