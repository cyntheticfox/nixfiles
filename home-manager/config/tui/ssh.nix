_: {
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
      "github github.com" = {
        hostname = "github.com";
        user = "git";
        port = 22;
        identityFile = "~/.ssh/github_id_ed25519";
      };
    };
  };
}
