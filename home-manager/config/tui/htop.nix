{ config, pkgs, ... }: {
  home.shellAliases."top" = "htop";

  programs.htop = {
    enable = true;

    settings = {
      color_scheme = 0;
      detailed_cpu_time = 1;
      cpu_count_from_zero = 0;
      delay = 15;
      fields = with config.lib.htop.fields; [
        PID
        USER
        PRIORITY
        NICE
        M_SIZE
        M_RESIDENT
        M_SHARE
        STATE
        PERCENT_CPU
        PERCENT_MEM
        TIME
        COMM
      ];
      header_margin = 1;
      hide_threads = 0;
      hide_kernel_threads = 1;
      hide_userland_threads = 0;
      highlight_base_name = 1;
      highlight_megabytes = 1;
      highlight_thread = 1;
      sort_key = config.lib.htop.fields.PERCENT_MEM;
      sort_direction = 1;
      tree_view = 1;
      update_process_names = 0;
    } // (with config.lib.htop; leftMeters [
      (bar "LeftCPUs")
      (bar "Memory")
      (bar "Swap")
    ]) // (with config.lib.htop; rightMeters [
      (bar "RightCPUs")
      (text "Tasks")
      (text "LoadAverage")
      (text "Uptime")
    ]);
  };
}
