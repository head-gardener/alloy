check:
  nix eval ./example#nixosConfigurations.client.config.nix.settings.substituters

docs:
  nix build .#docs
