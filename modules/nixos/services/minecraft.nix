{ pkgs, vars, ... }:

{
  networking.firewall.allowedTCPPorts = [ vars.services.minecraft.port ];
  networking.firewall.allowedUDPPorts = [ vars.services.minecraft.port ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    dataDir = "/var/lib/minecraft-servers";

    servers.paper-server = {
      enable = true;
      package = pkgs.papermcServers.papermc;

      serverProperties = {
        server-port = vars.services.minecraft.port;
        enable-query = true;
        "query.port" = vars.services.minecraft.port;
        enable-rcon = false;
      };
    };
  };
}
