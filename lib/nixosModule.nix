{ lib, ... }:
let
  inherit (lib) mkOption types;
in {
  options.alloy = {
    extend = mkOption {
      type = with types; lazyAttrsOf (listOf raw);
      default = { };
      description = ''
        Configurations to extend. Should contain a list of modules.
      '';
    };
  };
}
