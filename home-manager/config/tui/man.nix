{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    libcap_manpages
    linux-manual
    llvmPackages_latest.clang-manpages
    llvmPackages_latest.llvm-manpages
    manpages
    posix_man_pages
    stdmanpages
  ];

  programs.man = {
    enable = true;
    generateCaches = true;
  };
}
