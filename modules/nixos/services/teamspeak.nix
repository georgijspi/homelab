{ config, pkgs, ... }:

{
  services.teamspeak3 = {
    enable = true;
    openFirewall = false; # Ports are managed in hosts/falcon/networking.nix.
  };
}
