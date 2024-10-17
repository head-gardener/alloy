#! /usr/bin/env bash

compare () {
  nix eval ".#$1" --json 2>/dev/null | jq . | grep -v null | diff --color -C 5 "$2" -
}

compare nixosConfigurations.client.config.nix.settings.substituters substituters.txt

compare nixosConfigurations.server.config.services.prometheus.scrapeConfigs prometheus.txt
