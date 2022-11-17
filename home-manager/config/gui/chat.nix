{ pkgs, ... }: {
  home.packages = with pkgs; [
    nixpkgs-unstable.discord
    nixpkgs-unstable.element-desktop
  ];

  home.sessionVariables."NIXOS_OZONE_WL" = 1;

  xdg.configFile."discord/settings.json".source = (pkgs.formats.json { }).generate "settings.json" {
    IS_MAXIMIZED = true;
    IS_MINIMIZED = false;
    SKIP_HOST_UPDATE = true;
  };
}
