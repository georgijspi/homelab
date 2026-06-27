{ vars, ... }:

let
  network = vars.network;
  firewall = network.firewall;

  rejectTCP = port: ''
    iptables -A nixos-fw -p tcp ! -s ${network.lanCidr} --dport ${toString port} -j REJECT
  '';
  rejectUDP = port: ''
    iptables -A nixos-fw -p udp ! -s ${network.lanCidr} --dport ${toString port} -j REJECT
  '';
in
{
  networking = {
    firewall = {
      allowedTCPPorts = firewall.baseAllowedTCPPorts;
      allowedUDPPorts = firewall.baseAllowedUDPPorts;

      extraCommands =
        builtins.concatStringsSep "\n"
          ((map rejectTCP firewall.lanOnlyTCPPorts) ++ (map rejectUDP firewall.lanOnlyUDPPorts));
    };

    useDHCP = false;

    interfaces.${network.interface} = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = network.hostAddress;
          prefixLength = network.prefixLength;
        }
      ];
    };

    defaultGateway = network.gateway;
    nameservers = network.nameservers;
  };

  services.resolved.settings = {
    Resolve = {
      DNSStubListener = "no";
    };
  };

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = null;
      X11Forwarding = false;
    };
  };
}
