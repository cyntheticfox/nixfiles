{ lib, pkgs, ... }: {
  environment.packages = with pkgs; [
    neovim
    zsh
    zoxide
    ripgrep
    git

    diffutils
    findutils
    utillinux
    tzdata
    hostname
    man
    gnugrep
    gnused
    gnutar
    bzip2
    xz
    zip
    unzip
  ];

  # Backup etc files instead of failing to activate
  environment.etcBackupExtension = ".bak";

  # Set up nix for flakes
  nix.extraOptions = "experimental-features = nix-command flakes";

  user.shell = lib.getExe pkgs.zsh;

  home-manager.useUserPackages = true;

  time.timeZone = "America/New_York";
}
