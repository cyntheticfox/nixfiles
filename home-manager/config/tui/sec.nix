{ pkgs, ... }: {
  home.packages = with pkgs; [
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
}
