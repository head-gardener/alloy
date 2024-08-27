alloyFlake: { lib, flake-parts-lib, config, inputs, ... }:
let
  inherit (lib) mkIf mkOption types;

  opts = config.flake.alloy;
in
{
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      alloy = {
        nixosConfigurations = mkOption {
          type = types.lazyAttrsOf types.raw;
          default = { };
          description = ''
            Instantiated NixOS configurations to apply alloy to. Used by `nixos-rebuild`.
          '';
        };

        config = mkOption {
          type = types.either (types.listOf types.raw) (types.raw);
        };
      };
    };
  };

  config = {
    flake.nixosConfigurations = mkIf (opts.config != null)
      (alloyFlake.lib.apply opts.config opts.nixosConfigurations);
  };
}
