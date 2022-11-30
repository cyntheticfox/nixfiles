{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.sys.core;

  pkgModule = { packages, type, extraOptions ? { } }: types.submodule (_: {
    options = {
      enable = mkEnableOption "Manage ${pkgType} packages";

      packages = mkOption {
        type = with types; listOf package;
        default = packages;
      };
    } // extraOptions;
  });

  fileModule = pkgModule {
    type = "file";
    packages = with pkgs; [
      fq
      man-pages
      p7zip
      ripgrep
      sd
      unzip
      zip

      # Document packages
      glow
      pandoc
      xsv

      # FUSE Packages
      exfat
      gocryptfs
      fuseiso
      jmtpfs
      ntfs3g
      smbnetfs
    ];
  };

  netModule = pkgModule {
    type = "network";
    packages = with pkgs; [
      bandwhich
      curlie
      dogdns
      gping
      mtr
      traceroute
      whois
      xh
    ];
  };

  procModule = pkgModule {
    type = "process";
    packages = with pkgs; [
      nodePackages.fkill-cli
      procs
    ];

    extraOptions.htopIntegration = mkEnableOption "Manage htop configuration" // { default = true; };
  };
in
{
  options.sys.core = {
    enable = mkEnableOption "Enable core configuration packages" // { default = true; };

    extraPaths = mkOption {
      type = with types; listOf string;
      default = with pkgs; [
        "${config.home.homeDirectory}/.cargo/bin"
      ];
      description = ''
        Additional packages to add to the user's session path.
      '';
    };

    manageFilePackages = mkOption {
      type = fileModule;
      default = { };
      description = "Options for managing installed file packages";
    };

    manageNetworkPackages = mkOption {
      type = netModule;
      default = { };
      description = "Options for managing installed network packages";
    };

    manageProcessPackages = mkOption {
      type = procModule;
      default = { };
      description = "Options for managing installed process packages";
    };

    manageXDGConfig = mkEnableOption "Enable xdg dirs management" // { default = true; };

    manageNixConfig = mkEnableOption "Enable Nix config management" // { default = true; };

    neofetch = mkEnableOption "Enable neofetch config" // { default = true; };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
      ];

      home.sessionPath = cfg.extraPaths;

      programs.man = {
        enable = true;

        generateCaches = true;
      };
    }
    (mkIf cfg.manageFilePackages.enable {
      home.packages = cfg.manageFilePackages.packages;

      home.shellAliases."glow" = "glow -p";

      programs.texlive = {
        enable = true;

        extraPackages = p: { inherit (p) collection-fontsrecommended; };
      };
    })
    (mkIf cfg.manageNetworkPackages.enable {
      home.packages = cfg.manageNetworkPackages.packages;

      home.shellAliases."tracert" = "traceroute";
    })
    (mkIf cfg.manageProcessPackages.enable {
      home.packages = cfg.manageProcessPackages.packages;

      home.shellAliases."top" = "htop";

      programs.htop = mkIf cfg.manageProcessPackages.htopIntegration {
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
    })
    (mkIf cfg.manageNixConfig
      {
        home.packages = with pkgs; [
          comma
          nvd
        ];
        home.shellAliases = {
          ### Nix Aliases
          # TODO: Make this a separate like OMZ module?
          #
          "n" = "nix";

          "nb" = "nix build";
          "nbr" = "nix build --rebuild";

          "nd" = "nix develop";

          "nf" = "nix flake";
          "nfc" = "nix flake check";
          "nfcl" = "nix flake clone";
          "nfi" = "nix flake init";
          "nfl" = "nix flake lock";
          "nfm" = "nix flake metadata";
          "nfs" = "nix flake show";
          "nfu" = "nix flake update";
          "nfuc" = "nix flake update && nix flake check";

          "nfmt" = "nix fmt";

          "nlog" = "nix log";

          "np" = "nix profile";
          "nph" = "nix profile history";
          "npi" = "nix profile install";
          "npl" = "nix profile list";
          "npu" = "nix profile upgrade";
          "nprm" = "nix profile remove";
          "nprb" = "nix profile rollback";
          "npw" = "nix profile wipe-history";

          "nr" = "nix run";

          "nrepl" = "nix repl";

          "nreg" = "nix registry";
          "nregls" = "nix registry list";

          "ns" = "nix search";
          "nsn" = "nix search nixpkgs";
          "nsu" = "nix search nixpkgs-unstable";

          "nsh" = "nix shell";
          # TODO: Replace w/ working function
          # "nshn" = "nix shell nixpkgs";

          "nst" = "nix store";
        } // (if builtins.hasAttr "ON_NIXOS" config.home.sessionVariables then {
          "nos" = "nixos-rebuild";
          "nosb" = "nixos-rebuild build";
          "nosbf" = "nixos-rebuild build --flake .";
          "nosc" = "nixos-container";
          "nosg" = "nixos-generate-config";
          "nossw" = "nixos-rebuild switch --use-remote-sudo";
          "nosswf" = "nixos-rebuild switch --use-remote-sudo --flake .";
          "nosswfc" = "nix flake check && nixos-rebuild switch --use-remote-sudo --flake .";
          "nosswfuc" = "nix flake update && nix flake check && nixos-rebuild switch --use-remote-sudo --flake .";
          "nosswrb" = "nixos-rebuild switch --use-remote-sudo --rollback";
        } else {
          "nos" = "home-manager";
          "nosb" = "home-manager build";
          "nosbf" = "home-manager build --flake .#$(hostname)";
          "nossw" = "home-manager switch";
          "nosswf" = "home-manager switch --flake .#$(hostname) -b '.bak'";
          "nosswfc" = "nix flake check && home-manager switch --flake .#$(hostname) -b '.bak'";
          "nosswfuc" = "nix flake update && nix flake check && home-manager switch --flake .#$(hostname) -b '.bak'";
          # "nosswrb" = "home-manager switch --rollback";
        });


        nix.registry = mkDefault {
          ### Nixpkgs
          #

          # nixpkgs-unstable.to = {
          #   type = "github";
          #   owner = "NixOS";
          #   repo = "nixpkgs";
          #   ref = "nixos-unstable";
          # };

          # # TODO: Make dynamic
          # nixpkgs.to = {
          #   type = "github";
          #   owner = "NixOS";
          #   repo = "nixpkgs";
          #   ref = "nixos-22.05";
          # };

          ### Other people's configs
          #
          foosteros.to = {
            type = "github";
            owner = "lilyinstarlight";
            repo = "foosteros";
          };

          ### Build tools
          #
          naersk.to = {
            type = "github";
            owner = "nix-community";
            repo = "naersk";
          };

          napalm.to = {
            type = "github";
            owner = "nix-community";
            repo = "napalm";
          };

          node2nix.to = {
            type = "github";
            owner = "svanderburg";
            repo = "node2nix";
          };

          pre-commit-nix.to = {
            type = "github";
            owner = "cachix";
            repo = "pre-commit.nix";
          };
        };

        nixpkgs.config.allowUnfree = mkDefault true;

        programs.nix-index.enable = mkDefault true;
      })
    (mkIf cfg.manageXDGConfig {
      xdg = {
        enable = mkDefault true;
        cacheHome = mkDefault "${config.home.homeDirectory}/.cache";
        configHome = mkDefault "${config.home.homeDirectory}/.config";
        dataHome = mkDefault "${config.home.homeDirectory}/.local/share";
        stateHome = mkDefault "${config.home.homeDirectory}/.local/state";

        userDirs = {
          enable = mkDefault true;

          createDirectories = mkDefault true;

          desktop = mkDefault "${config.home.homeDirectory}";
          documents = mkDefault "${config.home.homeDirectory}/docs";
          download = mkDefault "${config.home.homeDirectory}/tmp";
          music = mkDefault "${config.home.homeDirectory}/music";
          pictures = mkDefault "${config.home.homeDirectory}/pics";
          publicShare = mkDefault "${config.home.homeDirectory}/public";
          templates = mkDefault "${config.home.homeDirectory}/.templates";
          videos = mkDefault "${config.home.homeDirectory}/videos";

          extraConfig = mkDefault {
            "XDG_SECRETS_DIR" = "${config.home.homeDirectory}/.secrets";
          };
        };
      };
    })
    (mkIf cfg.neofetch {
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
    })
  ]);
}
