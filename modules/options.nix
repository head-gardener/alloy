{ lib, ... }:
let
  inherit (lib) mkOption types id;
in
{
  options = {
    settings = {
      extraSpecialArgs = lib.mkOption {
        type = types.attrsOf types.raw;
        default = {};
        description = ''
          Extra specialArgs to pass to imported modules.
        '';
      };

      resolve = lib.mkOption {
        type = types.functionTo types.str;
        default = id;
        defaultText = "lib.id";
        description = ''
          Function used for resolving hostnames into addresses. Use `alloy-utils.fromTable` if you want to define it as an attribute set.
        '';
        example = ''
          alloy-utils.fromTable {
            server = "10.0.0.1";
            client = "10.0.0.2";
          }
        '';
      };
    };

    modules = lib.mkOption {
      type = types.attrsOf types.raw;
      default = { };
      description = ''
        Attribute set of module definitions. Their args will include `alloy`, which can be used to access configuration of other modules in this set.
      '';
      example = ''
        {
          nix-serve = ./nix-serve.nix;
          cache = { alloy, config, ... }: { };
        };
      '';
    };

    hosts = lib.mkOption {
      type = types.functionTo (types.attrsOf (types.listOf types.raw));
      default = lib.const { };
      defaultText = "lib.const { }";
      description = ''
        Function, that gets passed the attribute set from `modules` and returns an attribute set of configurations, with lists of modules to apply to them. In these lists you can only use the modules from the passed attribute set. Configurations defined here should be present in your original `nixosConfigurations` and will be extended with necessary modules.
      '';
      example = ''
        hosts = mods: with mods; {
          server = [ nix-serve ];
          client = [ cache ];
        };
      '';
    };
  };
}
