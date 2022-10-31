{ pkgs, ... }: {
  home.packages = with pkgs; [ neofetch ];

  xdg.configFile."neofetch/config.conf".text = ''
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

      kernel_shorthand="on"
      distro_shorthand="off"
      os_arch="on"
      uptime_shorthand="tiny"
      memory_percent="on"
      package_managers="on"
      speed_shorthand="on"
      cpu_temp="on"
      refresh_rate="on"
      gtk_shorthand="on"
      image_backend="kitty"
  '';
}
