# Alloy

`alloy` is a tool for managing interdependent services between different configurations inside a flake.

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

## Installation

To install `alloy` you can use `flake-parts` or do it yourself. 
- When using parts, add `alloy.flakeModule` to your imports, put your configuration in `flake.alloy.config` and move `flake.nixosConfigurations` to `flake.alloy.nixosConfigurations`. See [module defenition](./flake-module.nix) for details.
- When doing it yourself, wrap your `nixosConfigurations` in a call to `alloy.lib.apply`, providing configuration:

```nix
nixosConfigurations = alloy.lib.apply [ ./alloy_config.nix ] {
  host = { ... };
  # your configs
}
```

## Configuration

In general your configuration would look like this.

```nix
{
  modules = {
    module = ./module.nix; # anything that's considered a module
  };

  hosts = mods: with mods; {
    host = [ module ]; # what modules go where
  };
}
```

`alloy` configuration uses Nix modules, so you can use `imports`, `config`, etc. `alloy` modules have a special argument `alloy-utils`, which is `alloy.lib.utils`.

## Example

See `/example` for a complete flake, defining multiple interdependent configurations via `alloy`.

## TODO

- [x] make this a flake-parts module
- [x] use nix's module system for config
- [x] handle multi-instance services
- [ ] middleware
- [ ] remote extend
- [ ] documentation, errors
