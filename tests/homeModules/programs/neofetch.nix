{ lib, pkgs, ... }:

with lib;

{
  config = {
    programs.neofetch.enable = true;

    test.stubs.neofetch = { };

    nmt.script = ''
      assertDirectoryNotEmpty home-path/.config/neofetch
      assertFileExists home-path/.config/neofetch/neofetch.conf
      assertFileContent home-files/.config/neofetch/neofetch.conf ${
        pkgs.writeText "neofetch.conf" ''
          # Generated by [home-manager](https://github.com/nix-community/home-manager)



          print_info() {


              info title
              info underline
              info "OS" distro
              info "Host" model
              info "Kernel" kernel
              info "Uptime" uptime
              info "Packages" packages
              info "Shell" shell
              info "Resolution" resolution
              info "DE" de
              info "WM" wm
              info "WM Theme" wm_theme
              info "Theme" theme
              info "Icons" icons
              info "Terminal" term
              info "Terminal Font" term_font
              info "CPU" cpu
              info "GPU" gpu
              info "Memory" memory
              info cols


          }


        ''}
    '';
  };
}