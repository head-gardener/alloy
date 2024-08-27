# Alloy

Alloy is a tool for managing interdependent services between different configurations inside a flake.

## Overview

It works by allowing defined modules to access each other's configuration options from args.

```nix
{ alloy, ... }:
let
  inherit (alloy) nix-serve;
in
{
  nix.settings.substituters = [
    "http://${nix-serve.host}:${toString nix-serve.config.services.nix-serve.port}"
  ];
}
```

To install alloy add it to flake inputs and wrap your `nixosConfigurations` in a call to `alloy.lib.apply`, providing configuration:

```nix
nixosConfigurations = alloy.lib.apply
  {
    modules = {
      module = ./module.nix; # anything that's considered a module
    };

    hosts = mods: with mods; {
      host = [ module ]; # what modules go where
    };
  }
  {
    # your configs
    host = { ... };
  }
```

See `example` for a complete demonstration.

## TODO

- (x) make this a flake-parts module
- ( ) use nix's module system for configuring alloy
- ( ) handle multi-instance services
- ( ) documentation, errors
