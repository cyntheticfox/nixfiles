{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    aria2
    bind # for dig
    nmap
    openssh
    traceroute
    whois
  ];
}
