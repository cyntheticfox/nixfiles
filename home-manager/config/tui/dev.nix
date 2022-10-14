{ config, pkgs, ... }: {
  home.shellAliases = {
    "gcc" = "gcc -fdiagnostics-color";
    "clang" = "clang -fcolor-diagnostics";
  };

  home.packages = with pkgs; [
    act
    cargo
    cloc
    deno
    gcc_latest
    hexyl
    htmlq
    hyperfine
    jq
    (nixpkgs-unstable.llvmPackages_latest.clang.overrideAttrs (attrs: {
      meta.priority = gcc_latest.meta.priority + 1;
    }))
    nixpkgs-unstable.llvmPackages_latest.clang-manpages
    nodejs_latest
    pastel
    poetry
    python3

    # Repository Management
    pre-commit
    git-secrets
  ];

  programs.direnv = {
    enable = true;

    nix-direnv.enable = true;
  };

  programs.java = {
    enable = true;
    package = pkgs.openjdk;
  };

  programs.gh = {
    enable = true;

    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      pager = config.home.sessionVariables.PAGER;
      editor = config.home.sessionVariables.EDITOR;
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
  };

  # Load editorconfig file as well
  home.file.".editorconfig".text = ''
    # .editorconfig
    #
    # Source for controlling tabulation and formatting of files by name
    #
    # https://editorconfig.org
    #
    # Plugins required for...
    #
    # Vim: https://github.com/editorconfig/editorconfig-vim
    # Neovim: https://github.com/gpanders/editorconfig.nvim
    # VSCode/VSCodium: https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig

    root = true

    # Set file defaults
    [*]
    charset = utf-8
    end_of_line = lf
    indent_size = 4
    indent_style = space
    insert_final_newline = true
    trim_trailing_whitespace = true

    [*.md]
    indent_size = 2
    trim_trailing_whitespace = false

    [Makefile]
    indent_size = 8
    indent_style = tab

    # Default to two spaces for data languages
    [*.{c,cpp,css,h,hpp,htm,html,js,json,lua,mof,nix,ps1,psd1,psm1,rst,tf,ts,vue,yml,yaml,xml,xhtml}]
    indent_size = 2
    indent_style = space

    [flake.lock]
    indent_size = 2
    indent_style = space
  '';
}
