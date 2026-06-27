{ pkgs, vars, ... }:

let
  wg = vars.network.wireguard;
  privateKeyFile = "${wg.keyPath}/server-private.key";
in
{
  environment.systemPackages = with pkgs; [
    wireguard-tools
    qrencode
  ];

  networking.nat.enable = true;
  networking.nat.externalInterface = wg.externalInterface;
  networking.nat.internalInterfaces = [ "wg0" ];

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ wg.listenPort ];
    trustedInterfaces = [ "wg0" ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ wg.serverIPv4 wg.serverIPv6 ];
    listenPort = wg.listenPort;
    privateKeyFile = privateKeyFile;

    postSetup = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${wg.ipv4Cidr} -o ${wg.natPostroutingInterface} -j MASQUERADE
      ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s ${wg.ipv6Cidr} -o ${wg.natPostroutingInterface} -j MASQUERADE
    '';
    postShutdown = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${wg.ipv4Cidr} -o ${wg.natPostroutingInterface} -j MASQUERADE
      ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s ${wg.ipv6Cidr} -o ${wg.natPostroutingInterface} -j MASQUERADE
    '';

    peers = map
      (peer: {
        publicKey = peer.publicKey;
        allowedIPs = peer.allowedIPs;
      })
      wg.peers;
  };
}
