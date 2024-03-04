{ config, lib, pkgs, ... }:

let
  cfg = config.sys.core;

  nixDiffCommands = {
    builtin = "nix store diff-closures";
    nvd = "nvd diff";
    nix-diff = "nix-diff";
  };
in
{
  options.sys.core = {
    enable = lib.mkEnableOption "Enable core configuration packages" // { default = true; };

    extraPaths = lib.mkOption {
      type = with lib.types; listOf string;
      default = [ "${config.home.homeDirectory}/.cargo/bin" ];

      description = ''
        Additional packages to add to the user's session path.
      '';
    };

    file = {
      enable = lib.mkEnableOption "file packages" // { default = true; };

      packages = lib.mkOption {
        type = with lib.types; listOf package;

        default = with pkgs; [
          coreutils-full
          file
          fd
          fq
          man-pages
          p7zip
          ripgrep
          sd
          unzip
          zip
          xdg-utils

          # Document packages
          glow
          ghostscript
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

        description = ''
          Options for managing installed file packages.
        '';
      };
    };

    network = {
      enable = lib.mkEnableOption "network packages" // { default = true; };

      packages = lib.mkOption {
        type = with lib.types; listOf package;

        default = with pkgs; [
          aria
          bandwhich
          cifs-utils
          curlie
          dogdns
          gping
          inetutils
          mtr
          nfs-utils
          xh
        ];

        description = ''
          Packages for network management.
        '';
      };
    };

    hardware = {
      enable = lib.mkEnableOption "hardware packages" // { default = true; };

      packages = lib.mkOption {
        type = with lib.types; listOf package;

        default = with pkgs; [
          minicom
          screen
          usbutils
          pciutils
          nvme-cli
        ];

        description = ''
          Packages for network management.
        '';
      };
    };

    process = {
      enable = lib.mkEnableOption "process packages";

      packages = lib.mkOption {
        type = with lib.types; listOf package;

        default = with pkgs; [
          nodePackages.fkill-cli
          procs
          strace
        ];

        description = ''
          Packages for process management.
        '';
      };

      htopIntegration = lib.mkEnableOption "htop configuration" // { default = true; };
    };

    xdg.enable = lib.mkEnableOption "xdg dirs management" // { default = true; };

    nix = {
      enable = lib.mkEnableOption "Nix config management" // { default = true; };
      package = lib.mkPackageOption pkgs "nixUnstable" { };

      diffProgram = lib.mkOption {
        type = lib.types.enum (builtins.attrNames nixDiffCommands);

        default = assert builtins.hasAttr "builtin" nixDiffCommands; "builtin";
      };

      cachix = {
        enable = lib.mkEnableOption "cachix" // { default = true; };
        package = lib.mkPackageOption pkgs "cachix" { };
      };
    };

    neofetch.enable = lib.mkEnableOption "neofetch config" // { default = true; };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.sessionPath = cfg.extraPaths;

      programs.man = {
        enable = true;

        generateCaches = true;
      };
    }

    (lib.mkIf cfg.file.enable {
      home = {
        inherit (cfg.file) packages;

        shellAliases."glow" = "glow -p";
      };

      programs.texlive = {
        enable = true;

        extraPackages = p: { inherit (p) collection-fontsrecommended; };
      };
    })

    (lib.mkIf cfg.network.enable {
      home = {
        inherit (cfg.network) packages;

        shellAliases."tracert" = "traceroute";
      };
    })

    (lib.mkIf cfg.process.enable {
      home = {
        inherit (cfg.process) packages;

        shellAliases."top" = "htop";
      };

      programs.htop = lib.mkIf cfg.process.htopIntegration {
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

    (lib.mkIf cfg.hardware.enable {
      home.packages = cfg.hardware.packages;
    })

    (lib.mkIf cfg.nix.enable {
      home = {
        packages = [ pkgs.comma ]
          ++ lib.optional (cfg.nix.diffProgram != "builtin") [ pkgs.${cfg.nix.diffProgram} ]
          # ++ lib.optional cfg.nix.cachix.enable [ cfg.nix.cachix.package ]
        ;

        shellAliases = {
          ### Nix Aliases
          # TODO: Make this a separate like OMZ module?
          #
          "n" = "nix";

          "nb" = "nix build";
          "nbr" = "nix build --rebuild";

          "nd" = builtins.getAttr cfg.nix.diffProgram nixDiffCommands; # TODO: Make diff

          "ndev" = "nix develop";

          "ne" = "nix edit";

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

          "npath" = "nix path-info";

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

          "nsd" = "nix show-derivation";

          "nst" = "nix store";
        } // (if builtins.hasAttr "ON_NIXOS" config.home.sessionVariables then {
          "nos" = "nixos-rebuild";
          "nosb" = "nixos-rebuild build";
          "nosbf" = "nixos-rebuild build --flake .";
          "nosc" = "nixos-container";
          "nosd" = "";
          "nosg" = "nixos-generate-config";
          "nosp" = "read-link '/nix/var/nix/profiles/system'";
          "nospl" = "ls -r '/nix/var/nix/profiles/system-*'";
          "nossw" = "nixos-rebuild switch --use-remote-sudo";
          "nosswf" = "nixos-rebuild switch --use-remote-sudo --flake .";
          "nosswfc" = "nix flake check && nixos-rebuild switch --use-remote-sudo --flake .";
          "nosswfuc" = "nix flake update && nix flake check && nixos-rebuild switch --use-remote-sudo --flake .";
          "nosswrb" = "nixos-rebuild switch --use-remote-sudo --rollback";
          "nosv" = "nixos-version";
        } else {
          "nos" = "home-manager";
          "nosb" = "home-manager build";
          "nosbf" = "home-manager build --flake .#`hostname`";
          "nossw" = "home-manager switch";
          "nosswf" = "home-manager switch --flake .#`hostname` -b '.bak'";
          "nosswfc" = "nix flake check && home-manager switch --flake .#`hostname` -b '.bak'";
          "nosswfuc" = "nix flake update && nix flake check && home-manager switch --flake .#`hostname` -b '.bak'";
          # "nosswrb" = "home-manager switch --rollback"; # FIXME: Find a workaround?
        });
      };


      nix = {
        package = lib.mkDefault cfg.nix.package;

        registry = {
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
      };

      nixpkgs.config.allowUnfree = true;
    })

    (lib.mkIf cfg.xdg.enable {
      xdg = {
        inherit (cfg.xdg) enable;

        cacheHome = lib.mkDefault "${config.home.homeDirectory}/.cache";
        configHome = lib.mkDefault "${config.home.homeDirectory}/.config";
        dataHome = lib.mkDefault "${config.home.homeDirectory}/.local/share";
        stateHome = lib.mkDefault "${config.home.homeDirectory}/.local/state";

        userDirs = {
          enable = lib.mkDefault true;

          createDirectories = lib.mkDefault true;

          desktop = lib.mkDefault "${config.home.homeDirectory}";
          documents = lib.mkDefault "${config.home.homeDirectory}/docs";
          download = lib.mkDefault "${config.home.homeDirectory}/tmp";
          music = lib.mkDefault "${config.home.homeDirectory}/music";
          pictures = lib.mkDefault "${config.home.homeDirectory}/pics";
          publicShare = lib.mkDefault "${config.home.homeDirectory}/public";
          templates = lib.mkDefault "${config.home.homeDirectory}/.templates";
          videos = lib.mkDefault "${config.home.homeDirectory}/videos";

          extraConfig = lib.mkDefault {
            "XDG_SECRETS_DIR" = "${config.home.homeDirectory}/.secrets";
          };
        };
      };
    })

    (lib.mkIf cfg.neofetch.enable {
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
