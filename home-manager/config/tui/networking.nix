{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    aria2
    bind # for dig
    netcat
    nmap
    openssh
    sshfs
    traceroute
    whois
    wireguard
  ];
}
