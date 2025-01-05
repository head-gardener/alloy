{ config, alloy, ... }: {
  alloy.extend.nginx = [
    {
      services.nginx.virtualHosts."darkhttpd" = {
        enableACME = false;
        locations."/".proxyPass =
          "http://${alloy.self.address}:${toString config.services.darkhttpd.port}";
      };
    }
  ];

  services.darkhttpd = {
    enable = true;
    address = "0.0.0.0";
    rootDir = /opt/www;
  };
}
