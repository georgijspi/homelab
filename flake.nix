{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

    copyparty.url = "github:9001/copyparty";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      varsPath =
        let
          fromEnv = builtins.getEnv "NIXOS_VARS";
        in
        if fromEnv != "" then fromEnv else "/etc/nixos/vars.nix";
      vars = import varsPath;

      falcon = nixpkgs.lib.nixosSystem {
        system = vars.host.system;
        specialArgs = {
          inherit inputs vars;
        };
        modules = [
          ./hosts/falcon
          inputs.home-manager.nixosModules.home-manager
        ];
      };
    in
    {
      nixosConfigurations = {
        inherit falcon;
      };
    };
}
