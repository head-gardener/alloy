check:
  cd example && rm -f ./flake.lock && ./run.sh

docs:
  nix build .#docs
