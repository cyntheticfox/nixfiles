{ pkgs, ... }: {
  home.packages = with pkgs; [
    exfat
    gocryptfs
    fuseiso
    jmtpfs
    ntfs3g
    smbnetfs
  ];
}
