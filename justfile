check:
  cd example && nix flake update alloy --option warn-dirty false && ./run.sh

docs:
  nix build .#docs
