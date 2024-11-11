alloyFlake: {
  lib,
  flake-parts-lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkOption types;

  cfg = config.flake.alloy;
in {
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      alloy = {
        nixosConfigurations = mkOption {
          type = types.lazyAttrsOf types.raw;
          default = {};
          description = ''
            Instantiated NixOS configurations to apply alloy to. Used by `nixos-rebuild`.
          '';
        };

        extraSpecialArgs = mkOption {
          type = types.lazyAttrsOf types.raw;
          default = {};
          description = ''
            Special args to pass to alloy configuration modules.
          '';
        };

        config = mkOption {
          type = with types; nullOr (either (listOf raw) raw);
        };
      };
    };
  };

  config = {
    flake.nixosConfigurations =
      mkIf (cfg.config != null)
      (alloyFlake.lib.apply cfg);
  };
}
