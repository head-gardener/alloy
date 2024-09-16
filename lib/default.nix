lib:
let
  inherit (lib) attrNames elem filterAttrs mapAttrs fix flip pipe;

  utils = {
    fromTable = table: x: table.${x};
  };

  evalAlloyConfig = conf:
    let
      baseModules = [
        ../modules/options.nix
      ];

      userModules = if builtins.isList conf then conf else [ conf ];

      finalConf = lib.evalModules {
        modules = baseModules ++ userModules;
        specialArgs = { alloy-utils = utils; };
      };
    in
    finalConf;
in
{
  inherit utils;

  mkDocs = { pkgs }:
  let
    eval = evalAlloyConfig [ ];
    docs = pkgs.nixosOptionsDoc { inherit (eval) options; };
  in docs;

  apply = conf: super:
    let

      inherit ((evalAlloyConfig conf).config)
        hosts
        modules
        settings;

      valsToNames = mapAttrs (n: _: n);

      getHosts = module: attrNames
        (filterAttrs
          (_: xs: elem module xs)
          (hosts (valsToNames modules)));

      mkAlloy = hosts:
        let
          toArg = n: _:
            let
              hostname = lib.head (getHosts n);
            in
            {
              host = settings.resolve hostname;
              config = hosts.${hostname}.config;
            };

          result = mapAttrs toArg modules;
        in
        result;

      mkHosts = alloy:
        let
          extend = h: ms: super.${h}.extendModules {
            modules = ms;
            specialArgs = { inherit alloy; } // settings.extraSpecialArgs;
          };
        in
        mapAttrs extend (hosts modules);

      hostsFixedPoint = fix ((flip pipe) [
        mkAlloy
        mkHosts
      ]);

    in
    super // hostsFixedPoint;
}
