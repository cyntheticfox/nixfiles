# david.nix
#
# User config for "david" user

{ config, pkgs, lib, outputs, ... }: {

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."david" = {
    isNormalUser = true;
    home = "/home/david";
    description = "David Houston";
    extraGroups = [ "wheel" "networkmanager" "audio" ]; # Enable ‘sudo’ for the user.
    uid = 1000;
    shell = pkgs.zsh;
  };

  environment.etc."lxc/default.conf" = lib.mkIf config.virtualisation.lxc.enable {
    mode = "0644";
    text = ''
      lxc.idmap = u ${builtins.toString config.users.users.david.uid} 100000 65536
      lxc.idmap = g ${builtins.toString config.users.users.david.uid} 100000 65536
    '';
  };

  home-manager.users.david = outputs.nixosModules."${config.networking.hostName}";
}
