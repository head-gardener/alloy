lib:
let
  inherit (lib) attrNames elem filterAttrs mapAttrs fix flip pipe;
in
{
  fromTable = table: x: table.${x};

  apply = conf: super:
    let
      inherit (conf) hosts modules;

      settings = { resolve = lib.id; } // (conf.settings or {});

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
            specialArgs = { inherit alloy; };
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
