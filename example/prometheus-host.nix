{ config, alloy, ... }:
{
  networking.firewall.allowedTCPPorts = [ config.services.prometheus.port ];

  services.prometheus = {
    enable = true;
    port = 4000;
    exporters = { };
    scrapeConfigs = alloy.prometheus-node.forEach (node: {
      job_name = node.hostname;
      static_configs = [{
        targets = [
          "${node.address}:${toString node.config.services.prometheus.exporters.node.port}"
        ];
      }];
    });
  };
}
