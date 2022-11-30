{ pkgs, ... }: {
  imports = [
    # ../home-manager/config/base.nix
    ../home-manager/config/sway.nix

    # GUI modules
    ../home-manager/config/gui/chat.nix
    ../home-manager/config/gui/dev.nix
    ../home-manager/config/gui/documents.nix
    ../home-manager/config/gui/games.nix
    ../home-manager/config/gui/libvirt.nix
    ../home-manager/config/gui/networking.nix
    ../home-manager/config/gui/teams.nix
    ../home-manager/config/gui/video.nix

    # Terminal modules
    ../home-manager/config/tui/podman.nix
  ];

  home.packages = with pkgs; [
    mozwire
  ];

  sys = {
    cloud = {
      enable = true;

      manageAwsConfig = true;
      manageAzureConfig = true;
      manageGcpConfig = true;
    };

    core = {
      enable = true;

      manageFilePackages.enable = true;
      manageNetworkPackages.enable = true;
      manageProcessPackages.enable = true;
    };

    dev.enable = true;
    fonts.enable = true;

    git = {
      enable = true;

      name = "David Houston";
      email = "houstdav000@gmail.com";
      gpgkey = "5960278CE235F821!";
    };

    keyboard.enable = true;
    music.enable = true;
    neovim.enable = true;
    sec.enable = true;

    shell = {
      enable = true;

      fcp = true;
    };

    ssh.enable = true;
  };
}
