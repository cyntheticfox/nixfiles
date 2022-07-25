{ config, pkgs, lib, ... }: {
  home.packages = with pkgs; [
    powershell
  ];

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    shellAliases = {
      "h" = "history";

      # Editor aliases
      "v" = config.home.sessionVariables.EDITOR;

      # List Aliases
      "l" = "ls";
      "ls" = "${pkgs.exa}/bin/exa --classify --color=always --icons";
      "la" = "ls --long --all --binary --group --header --git --color-scale";
      "tree" = "la --tree";

      # Standard program aliases
      "cat" = "${pkgs.bat}/bin/bat";
      "top" = "${pkgs.htop}/bin/htop";
      "ps" = "${pkgs.procs}/bin/procs";
      "more" = "less";
      "less" = config.home.sessionVariables.PAGER;

      # GCC and Clang coloring
      "gcc" = "gcc -fdiagnostics-color";
      "clang" = "clang -fcolor-diagnostics";

      # man page coloring
      "man" = lib.concatStringsSep " " [
        "LESS_TERMCAP_mb=$'\\e[01;31m'"
        "LESS_TERMCAP_md=$'\\e[01;34m'"
        "LESS_TERMCAP_me=$'\\e[0m'"
        "LESS_TERMCAP_se=$'\\e[0m'"
        "LESS_TERMCAP_so=$'\\e[01;31m'"
        "LESS_TERMCAP_ue=$'\\e[0m'"
        "LESS_TERMCAP_us=$'\\e[01;32m'"
        "man"
      ];

      # Nix flakes
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

      "nfmt" = "nix fmt";

      "nlog" = "nix log";

      "nos" = "nixos-rebuild";
      "nosb" = "nixos-rebuild build";
      "nosbo" = "nixos-reubuild boot";
      "nose" = "nixos-rebuild edit";
      "nossw" = "nixos-rebuild switch --use-remote-sudo";
      "nosswf" = "nixos-rebuild switch --use-remote-sudo --flake .";
      "nosswrb" = "nixos-rebuild switch --use-remote-sudo --rollback";
      "nost" = "nixos-rebuild test";
      "nosv" = "nixos-rebuild build-vm";
      "nosvb" = "nixos-rebuild build-vm-with-bootloader";

      "np" = "nix profile";
      "nph" = "nix profile history";
      "npi" = "nix profile install";
      "npl" = "nix profile list";
      "npu" = "nix profile upgrade";
      "nprm" = "nix profile remove";
      "nprb" = "nix profile rollback";
      "npw" = "nix profile wipe-history";

      "nr" = "nix run";

      "nre" = "nix repl";

      "nreg" = "nix registry";

      "ns" = "nix search";
      "nsn" = "nix search nixpkgs";
      "nsm" = "nix search nixpkgs-master";

      "nsh" = "nix shell";
      "nshn" = "nix shell nixpkgs";

      "nst" = "nix store";
    };

    enableAutosuggestions = true;
    oh-my-zsh = {
      enable = true;

      plugins = [
        "aliases"
        "command-not-found"
        "docker"
        "encode64"
        "fd"
        "gh"
        "git"
        "git-auto-fetch"
        "git-extras"
        "git-flow"
        "git-lfs"
        "golang"
        "isodate"
        "python"
        "ripgrep"
        "rust"
        "systemd"
        "systemadmin"
        "tig"
        "terraform"
        "tmux"
        "urltools"
        "web-search"
      ];
    };

    plugins = [
      {
        name = "zsh-completions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-completions";
          rev = "0.33.0";
          sha256 = "sha256-cQSKjQhhOm3Rvnx9V6LAmtuPp/ht/O0IimpunoQlQW8=";
        };
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "fast-syntax-highlighting";
          rev = "v1.55";
          sha256 = "sha256-DWVFBoICroKaKgByLmDEo4O+xo6eA8YO792g8t8R7kA=";
        };
      }
      {
        name = "history-search-multi-word";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "history-search-multi-word";
          rev = "5b44d8cea12351d91fbdc3697916556f59f14b8c";
          sha256 = "sha256-B+I53Y2E6dB2hqSc75FkYwzY4qAVMGzcNWu8ZXytIoc=";
        };
      }
      {
        name = "zsh-you-should-use";
        src = pkgs.fetchFromGitHub {
          owner = "MichaelAquilina";
          repo = "zsh-you-should-use";
          rev = "1.7.3";
          sha256 = "sha256-/uVFyplnlg9mETMi7myIndO6IG7Wr9M7xDFfY1pG5Lc=";
        };
      }
    ];

    history = {
      size = 102400;
      save = 10240;
      ignorePatterns = [
        "rm *"
        "pkill *"
        "cd *"
      ];
      expireDuplicatesFirst = true;
    };

    sessionVariables."ZSH_AUTOSUGGEST_USE_ASYNC" = "1";

    initExtraFirst = ''
      setopt AUTO_CD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT

      setopt ALWAYS_TO_END
      setopt AUTO_MENU
      setopt COMPLETE_IN_WORD
      setopt FLOW_CONTROL
    '';
  };

  programs.starship = {
    enable = true;

    settings = {
      add_newline = true;
      scan_timeout = 100;

      username = {
        format = "[$user]($style) in ";
        show_always = true;
        disabled = false;
      };

      hostname = {
        ssh_only = false;
        format = "⟨[$hostname](bold green)⟩ in ";
        disabled = false;
      };

      directory = {
        truncation_length = 3;
        fish_style_pwd_dir_length = 1;
      };

      shell = {
        disabled = false;
        bash_indicator = "bash";
        fish_indicator = "fish";
        powershell_indicator = "pwsh";
        elvish_indicator = "elvish";
        tcsh_indicator = "tcsh";
        xonsh_indicator = "xonsh";
        unknown_indicator = "?";
      };
    };
  };

  programs.direnv = {
    enable = true;

    nix-direnv.enable = true;
  };

  programs.zoxide.enable = true;
}
