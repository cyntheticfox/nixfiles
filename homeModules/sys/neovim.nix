{ config, lib, ... }:

let
  cfg = config.sys.neovim;
in
{
  options.sys.neovim = {
    enable = lib.mkEnableOption "Manage NeoVim editor configuration";

    # colorlist = lib.mkOption {
    #   type = with lib.types; listOf str;
    #   default = [
    #     "#cc241d"
    #     "#a89984"
    #     "#b16286"
    #     "#d79921"
    #     "#689d6a"
    #     "#d65d0e"
    #     # "#458588"
    #   ];
    #   description = ''
    #     List of colors to use in rainbow for indent, brackets.
    #   '';
    # };

  };

  config =
    #assert cfg.plugins.cmp-nvim-lsp.enable -> cfg.plugins.nvim-cmp.enable;

    lib.mkIf cfg.enable {
      home.sessionVariables = {
        "EDITOR" = lib.getExe config.programs.nixvim.finalPackage;
        "VISUAL" = "${lib.getExe config.programs.nixvim.finalPackage} -R";
      };

      home.shellAliases = {
        "vdiff" = "$EDITOR -d";
        "vsplit" = "$EDITOR -O2"; # Kinda wish I could just change the default behavior instead of this
        "vsudo" = "sudo -- $EDITOR -u ~/.config/nvim/init.vim";
      };

      programs.nixvim = {
        inherit (cfg) enable;

        autoGroups.FlakeLockFix = { };

        autoCmd = [
          {
            group = "FlakeLockFix";
            event = [ "BufNewFile" "BufRead" ];
            pattern = [ "flake.lock" ];
            command = "set filetype=json";
          }
        ];

        options = {
          colorcolumn = "80";
          completeopt = "menu,menuone,noinsert,noselect,preview";
          whichwrap = "b,s,<,>,h,l";
          cursorline = true;
          fileformats = "unix,dos,mac";
          foldcolumn = "1";
          guicursor = "n-c-v-sm:block-nCursor,i-ci-ve:ver25-iCursor,r-cr-o:hor20-Cursor,a:blinkwait300-blinkon200-blinkoff150";
          list = true;
          mouse = "a";
          number = true;
          scrolloff = 7;
          showmatch = true;
          showtabline = 2;
          termguicolors = true;
          timeoutlen = 500;
          title = true;

          # Set reasonable split behavior
          splitbelow = true;
          splitright = true;

          # Set Tab information
          expandtab = true;
          linebreak = true;
          shiftwidth = 4;
          smartindent = true;
          softtabstop = 4;
          textwidth = 500;

          # Set search options
          ignorecase = true;
          smartcase = true;

          # Backup options
          swapfile = false;
          writebackup = false;

          # better undo support
          undofile = true;
        };

        maps = {
          normal = {
            # leader mappings
            "<leader>et".action = ":tabe<CR>";
            "<leader>w".action = ":set wrap! wrap?<CR>";

            # Easier buffer switching
            "<leader>h".action = "<C-w>h";
            "<leader>j".action = "<C-w>j";
            "<leader>k".action = "<C-w>k";
            "<leader>l".action = "<C-w>l";

            # Easier terminal launch
            "<leader>tt" = {
              silent = true;
              action = ":terminal<CR>";
            };

            "<leader>tv" = {
              silent = true;
              action = ":vnew<CR>:terminal<CR>";
            };

            "<leader>th" = {
              silent = true;
              action = ":new<CR>:terminal<CR>";
            };
          };

          terminal = {
            "<C-x>".action = "<C-\><C-n><C-w>q";
            "<C-w>h".action = "<C-\><C-n><C-w>h";
            "<C-w>j".action = "<C-\><C-n><C-w>j";
            "<C-w>k".action = "<C-\><C-n><C-w>k";
            "<C-w>l".action = "<C-\><C-n><C-w>l";
          };
        };

        colorschemes.nord.enable = true;
        plugins = {
          barbar = {
            enable = true;
            keymaps = {
              silent = true;

              close = "<A-w>";
              goTo1 = "<A-1>";
              goTo2 = "<A-2>";
              goTo3 = "<A-3>";
              goTo4 = "<A-4>";
              goTo5 = "<A-5>";
              goTo6 = "<A-6>";
              goTo7 = "<A-7>";
              goTo8 = "<A-8>";
              goTo9 = "<A-9>";
              last = "<A-0>";
              moveNext = "<A->>";
              movePrevious = "<A-<>";
              next = "<A-.>";
              pin = "<A-p>";
              previous = "<A-,>";
            };
          };

          cmp-buffer.enable = true;
          cmp-cmdline.enable = true;
          cmp-cmdline-history.enable = true;
          cmp-git.enable = true;
          cmp-nvim-lsp-signature-help.enable = true;
          cmp-nvim-lsp.enable = true;
          cmp-pandoc-nvim.enable = true;
          cmp-path.enable = true;
          cmp-treesitter.enable = true;
          cmp-vsnip.enable = true;
          comment-nvim.enable = true;
          dashboard.enable = true;
          emmet.enable = true;
          gitgutter.enable = true;

          indent-blankline = {
            enable = true;

            showCurrentContext = true;
            showCurrentContextStart = true;

            charHighlightList = [
              "#cc241d"
              "#a89984"
              "#b16286"
              "#d79921"
              "#689d6a"
              "#d65d0e"
              # "#458588"
            ];
          };

          lsp = {
            enable = true;

            servers = {
              bashls.enable = true;
              # clangd.enable = true;
              # cssls.enable = true;
              # elixirls.enable = true;
              # eslint.enable = true;
              # gopls.enable = true;
              # hls.enable = true;
              # html.enable = true;
              # jsonls.enable = true;
              # lua-ls.enable = true;
              # pylsp.enable = true;
              # pyright.enable = true;
              rnix-lsp.enable = true;
              # rust-analyzer.enable = true;
              # texlab.enable = true;
              # tsserver.enable = true;
              # vuels.enable = true;

              # ccls = mkLspPlugin {
              #   name = "C Language Server";
              #   package = "ccls";
              #   moduleName = "ccls";
              # };

              # dockerfile-language-server = mkLspPlugin {
              #   name = "Dockerfile Language Server";
              #   packageSet = pkgs.nodePackages;
              #   package = "dockerfile-language-server-nodejs";
              #   moduleName = "dockerls";
              #   defaultArgs = [ "--stdio" ];
              # };

              # vscode-eslint = mkLspPlugin {
              #   name = "VSCode ESLint Language Server";
              #   packageSet = pkgs.nodePackages;
              #   package = "vscode-langservers-extracted";
              #   moduleName = "eslint";
              #   defaultArgs = [ "--stdio" ];
              #   binPath = "/bin/vscode-eslint-language-server";
              # };

              # terraformls = mkLspPlugin {
              #   name = "Terraform Language Server";
              #   package = "terraform-ls";
              #   moduleName = "terraformls";
              #   defaultArgs = [ "serve" ];
              # };

              # vimls = mkLspPlugin {
              #   name = "Vim Language Server";
              #   packageSet = pkgs.nodePackages;
              #   package = "vim-language-server";
              #   moduleName = "vimls";
              #   defaultArgs = [ "--stdio" ];
              # };

              # yamlls = mkLspPlugin {
              #   name = "YAML Language Server";
              #   packageSet = pkgs.nodePackages;
              #   package = "yaml-language-server";
              #   moduleName = "yamlls";
              # };
            };
          };

          lualine = {
            enable = true;
            theme = "nord";

            sections = {
              lualine_a = [{ name = "mode"; extraConfig.upper = true; }];
              lualine_b = [ "branch" ];
              lualine_c = [ "diff" "hostname" "filename" ];
              lualine_x = [ "encoding" "fileformat" "filetype" ];
              lualine_y = [ "progress" ];
              lualine_z = [ "location" ];
            };
          };

          nix.enable = true;

          # null-ls = {
          #   enable = true;
          #   sources = {
          #     code_actions.shellcheck.enable = true;
          #
          #     diagnostics = {
          #       cppcheck.enable = true;
          #       flake8.enable = true;
          #       gitlint.enable = true;
          #       shellcheck.enable = true;
          #
          #       # ansible-lint
          #       # cspell
          #       # clippy
          #       # flawfinder
          #       # nix-instantiate
          #       # pylint
          #       # statix
          #       # nix-lint
          #     };
          #
          #     formatting = {
          #       alejandra.enable = true;
          #       black.enable = true;
          #       cbfmt.enable = true;
          #       fnlfmt.enable = true;
          #       fourmolu.enable = true;
          #       prettier.enable = true;
          #       shfmt.enable = true;
          #       stylua.enable = true;
          #       taplo.enable = true;
          #       # go fmt
          #       # gofumpt
          #       # nixpkgs-fmt
          #       # rustfmt
          #       # terraform fmt
          #     };
          #   };
          # };

          nvim-autopairs = {
            enable = true;

            checkTs = true;

            # disabledFiletypes = [
            #   "TelescopePrompt"
            #   "spectre_panel"
            # ];
          };

          nvim-cmp.enable = true;
          nvim-colorizer.enable = true;
          surround.enable = true;

          # telescope.enable = true;

          treesitter = {
            enable = true;
            indent = true;
          };

          treesitter-context.enable = true;
        };
      };

      #   plugins = with pkgs.vimPlugins; [
      #     {
      #       plugin = impatient-nvim;
      #       type = "lua";
      #       config = "require('impatient')";
      #     }
      #     {
      #       plugin = indent-blankline-nvim-lua;
      #       type = "lua";
      #       config =
      #         let
      #           hlList = genHLList "IndentBlanklineIndent" cfg.colorlist;
      #         in
      #         ''
      #           ${hlList.luaVimCmdHLString}

      #           require('indent_blankline').setup {
      #             show_current_context = true,
      #             show_current_context_start = true,
      #             char_highlight_list = ${genLuaList hlList.hlGroupList}
      #           }
      #         '';
      #     }
      #     {
      #       plugin = scrollbar-nvim;
      #       config = ''
      #         augroup ScrollbarInit
      #           autocmd!
      #           autocmd WinScrolled,VimResized,QuitPre * silent! lua require('scrollbar').show()
      #           autocmd WinEnter,FocusGained * silent! lua require('scrollbar').show()
      #           autocmd WinLeave,BufLeave,BufWinLeave,FocusLost * silent! lua require('scrollbar').clear()
      #         augroup end
      #       '';
      #     }
      #     {
      #       plugin = telescope-nvim;
      #       type = "lua";
      #       config = ''
      #         require('telescope').setup({
      #           defaults = {
      #             vimgrep_arguments = {
      #               'rg',
      #               '--color=never',
      #               '--no-heading',
      #               '--with-filename',
      #               '--line-number',
      #               '--column',
      #               '--smart-case'
      #             },
      #             prompt_prefix = "> ",
      #             selection_caret = "> ",
      #             entry_prefix = " ",
      #             initial_mode = "insert",
      #             selection_strategy = "reset",
      #             sorting_strategy = "descending",
      #             layout_strategy = "horizontal",
      #             layout_config = {
      #               horizontal = {
      #                 mirror = false,
      #               },
      #               vertical = {
      #                 mirror = false,
      #               },
      #             },
      #             file_sorter = require'telescope.sorters'.get_fuzzy_file,
      #             file_ignore_patterns = {},
      #             eneric_sorter =  require'telescope.sorters'.get_generic_fuzzy_sorter,
      #             winblend = 0,
      #             border = {},
      #             borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
      #             color_devicons = true,
      #             use_less = true,
      #             set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
      #             file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
      #             grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
      #             qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,

      #             -- Developer configurations: Not meant for general override
      #             buffer_previewer_maker = require'telescope.previewers'.buffer_previewer_maker
      #           }
      #         })
      #       '';
      #     }
      #     {
      #       plugin = todo-comments-nvim;
      #       type = "lua";
      #       config = "require('todo-comments').setup()";
      #     }
      #     vim-eunuch
      #     vim-lastplace
      #     nvim-ts-autotag
      #     nvim-ts-context-commentstring
      #     nvim-ts-rainbow
    };
}
