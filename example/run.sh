#! /usr/bin/env bash

compare () {
  nix eval ".#$1" --json --option warn-dirty false \
    | jq . | grep -v null | diff --color -C 5 "test/$2" - \
    && echo "- $3 ok"
}

if [ "$1" == "bench" ]; then
  shift
  compare () {
    echo "- bencmark: $3"
    hyperfine "nix eval '.#$1' --json --option warn-dirty false"
  }
fi

compare \
  nixosConfigurations.client.config.nix.settings.substituters \
  substituters.json \
  "host resolution"

compare \
  nixosConfigurations.server.config.services.prometheus.scrapeConfigs \
  prometheus.json \
  "forEach"
