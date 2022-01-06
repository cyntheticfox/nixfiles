{ config, pkgs, ... }: {
  programs.ssh = {
    enable = true;
    compression = true;
    forwardAgent = false;
    hashKnownHosts = true;
    extraOptionOverrides = {
      identityFile = "~/.ssh/id_ed25519";
    };

    includes = [ "config.d/*" ];

    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/github_id_ed25519";
      };
    };
  };
}
