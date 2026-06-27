{ pkgs, vars, ... }:

{
  programs.zsh.enable = true;

  users.users.${vars.host.primaryUser.name} = {
    description = vars.host.primaryUser.description;
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
  };
}
