{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sys.sec;
in
{
  options.sys.sec = {
    enable = mkEnableOption "Manage security packages and tools";

    packages = mkOption {
      type = with types; listOf package;
      default = with pkgs; [
        # Android scanning
        trueseeing

        # Container scanning
        kubei
        trivy

        # Fuzzing
        aflplusplus
        crlfuzz

        # Password Crackers
        hcxtools
        hcxdumptool

        # Network Scanning
        nmap

        # Secret/File Scanning
        dirb
        gitleaks

        # Vuln/OS Scanning
        lynis
        spyre
        vulnix

        # WebApp Scanning
        nikto
        wapiti
      ];
      description = "Security-oriented packages and tools to install";
    };
  };

  config = mkIf cfg.enable {
    home.packages = cfg.packages;
  };
}
