{ lib, pkgs, inputs, vars, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./storage.nix

    ../../modules/nixos/base/users.nix
    ../../modules/nixos/base/packages.nix
    ../../modules/nixos/base/auto-upgrade.nix

    ../../modules/nixos/services/adguard.nix
    ../../modules/nixos/services/arr-stack.nix
    ../../modules/nixos/services/audiobookshelf.nix
    ../../modules/nixos/services/copyparty.nix
    ../../modules/nixos/services/ddclient.nix
    ../../modules/nixos/services/deluge.nix
    ../../modules/nixos/services/homepage.nix
    ../../modules/nixos/services/immich.nix
    ../../modules/nixos/services/jellyfin.nix
    ../../modules/nixos/services/minecraft.nix
    ../../modules/nixos/services/teamspeak.nix
    ../../modules/nixos/services/traefik.nix
    ../../modules/nixos/services/tt-rss.nix
    ../../modules/nixos/services/wireguard.nix
    ../../modules/nixos/services/zellij.nix

    inputs.nix-minecraft.nixosModules.minecraft-servers
    inputs.copyparty.nixosModules.default
    inputs.sops-nix.nixosModules.sops
  ];

  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
    inputs.copyparty.overlays.default
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = vars.host.name;
  time.timeZone = vars.host.timeZone;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "teamspeak-server" "claude-code" ];

  services.xserver.xkb.layout = "us";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit vars;
    };
    users.${vars.host.primaryUser.name} = import ../../home/zx;
  };

  sops = {
    defaultSopsFile = ../../secrets/falcon.yaml;
    age.keyFile = "/home/${vars.host.primaryUser.name}/.config/sops/age/keys.txt";
  };

  system.stateVersion = "25.05";
}
