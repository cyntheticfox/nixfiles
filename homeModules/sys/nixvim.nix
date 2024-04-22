{ config
, lib
, ...
}:
let
  cfg = config.sys.nixvim;
in
{
  options.sys.nixvim = {
    enable = lib.mkEnableOption "Manage NeoVim editor configuration";

    colorlist = lib.mkOption {
      type = with lib.types; listOf str;

      default = [
        "#cc241d"
        "#a89984"
        "#b16286"
        "#d79921"
        "#689d6a"
        "#d65d0e"
        # "#458588"
      ];

      description = ''
        List of colors to use in rainbow for indent, brackets.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables =
      let
        nvimBin = lib.getExe config.programs.nixvim.finalPackage;
      in
      {
        "EDITOR" = nvimBin;
        "VISUAL" = "${nvimBin} -R";
      };

    home.shellAliases = {
      "vdiff" = "$EDITOR -d";
      "vsplit" = "$EDITOR -O2"; # Kinda wish I could just change the default behavior instead of this
    };

    programs.nixvim =
      let
        prefix = "ColorLayer";

        charHighlightList = lib.imap1 (i: _: "${prefix}${builtins.toString i}") cfg.colorlist;
        vimHLString = lib.concatImapStringsSep "\n" (i: v: "vim.cmd [[highlight ${prefix}${builtins.toString i} guifg=${v} gui=nocombine]]") cfg.colorlist;
      in
      {
        inherit (cfg) enable;

        filetype.filename = {
          "flake.lock" = "json";
          ".ecrc" = "json";
        };

        opts = {
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

        keymaps = [
          # leader mappings
          {
            mode = "n";
            key = "<leader>et";
            action = ":tabe<CR>";
          }
          {
            mode = "n";
            key = "<leader>w";
            action = ":set wrap! wrap?<CR>";
          }

          # Easier buffer switching
          {
            mode = "n";
            key = "<leader>h";
            action = "<C-w>h";
          }
          {
            mode = "n";
            key = "<leader>j";
            action = "<C-w>j";
          }
          {
            mode = "n";
            key = "<leader>k";
            action = "<C-w>k";
          }
          {
            mode = "n";
            key = "<leader>l";
            action = "<C-w>l";
          }

          # Easier terminal launch
          {
            mode = "n";
            key = "<leader>tt";
            action = ":terminal<CR>";
            options.silent = true;
          }
          {
            mode = "n";
            key = "<leader>tv";
            action = ":vnew<CR>:terminal<CR>";
            options.silent = true;
          }
          {
            mode = "n";
            key = "<leader>th";
            action = ":new<CR>:terminal<CR>";
            options.silent = true;
          }
          {
            mode = "t";
            key = "<C-x>";
            action = "<C-\><C-n><C-w>q";
          }
          {
            mode = "t";
            key = "<C-w>h";
            action = "<C-\><C-n><C-w>h";
          }
          {
            mode = "t";
            key = "<C-w>j";
            action = "<C-\><C-n><C-w>j";
          }
          {
            mode = "t";
            key = "<C-w>k";
            action = "<C-\><C-n><C-w>k";
          }
          {
            mode = "t";
            key = "<C-w>l";
            action = "<C-\><C-n><C-w>l";
          }
        ];

        extraConfigLuaPost = vimHLString;
        colorschemes.onedark = {
          enable = true;

          settings.style = "darker";
        };

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

          comment.enable = true;
          emmet.enable = true;
          gitgutter.enable = true;
          indent-blankline.enable = true;
          lastplace.enable = true;

          lsp = {
            enable = true;

            servers = {
              ansiblels.enable = true; # Ansible
              bashls.enable = true; # Bash
              clangd.enable = true; # C/C++
              cssls.enable = true; # CSS
              # elixirls.enable = true; # Elixir
              dockerls.enable = true; # Docker
              # elmls.enable = true; # Elm
              # gopls.enable = true; # Go
              # hls.enable = true; # Haskell
              html.enable = true; # HTML
              jsonls.enable = true; # Json
              lua-ls.enable = true; # Lua
              nil_ls.enable = true; # Nix
              # pylsp.enable = true; # Python
              # pyright.enable = true; # Python
              # rnix-lsp.enable = true; # Nix
              ruff-lsp.enable = true; # Python

              # rust-analyzer = {
              #   enable = true;
              #
              #   installCargo = true;
              #   installRustc = true;
              # };

              # terraformls.enable = true; # Terraform
              texlab.enable = true; # TeX
              # tsserver.enable = true; # TypeScript
              # typst-lsp.enable = true;
              # vuels.enable = true; # Vue
              yamlls.enable = true; # YAML
              # zls.enable = true; # Zig
              # ccls.enable = true; # C/C++
            };
          };

          lsp-format.enable = true;

          lualine = {
            enable = true;

            theme = "onedark";

            sections = {
              lualine_a = [
                {
                  name = "mode";
                  extraConfig.upper = true;
                }
              ];
              lualine_b = [ "branch" ];
              lualine_c = [ "diff" "hostname" "filename" ];
              lualine_x = [ "encoding" "fileformat" "filetype" ];
              lualine_y = [ "progress" ];
              lualine_z = [ "location" ];
            };
          };

          neo-tree.enable = true;

          none-ls = {
            enable = true;
            enableLspFormat = true;

            sources = {
              code_actions = {
                proselint.enable = true;
                statix.enable = true;
              };

              completion = {
                luasnip.enable = true;
                spell.enable = true;
                vsnip.enable = true;
              };

              diagnostics = {
                actionlint.enable = true; # GitHub Actions
                ansiblelint.enable = true; # Ansible
                checkmake.enable = true; # Makefile
                # codespell.enable = true; # TODO: FIX
                commitlint.enable = true; # Gitcommit
                deadnix.enable = true; # Nix
                dotenv_linter.enable = true; # .env
                fish.enable = true; # fish script
                hadolint.enable = true; # Docker
                proselint.enable = true; # Markdown/Tex
                rstcheck.enable = true; # reStructuredText
                selene.enable = true; # Lua
                semgrep.enable = true; # Bunch of stuff
                markdownlint.enable = true; # Markdown
                sqlfluff.enable = true; # SQL
                statix.enable = true; # Nix
                stylelint.enable = true; # CSS
                tidy.enable = true; # HTML
                yamllint.enable = true; # YAML
              };

              formatting = {
                bibclean.enable = true; # BibTex
                cbfmt.enable = true; # Markdown codeblocks
                # codespell.enable = true; # TODO: Fix
                crystal_format.enable = true; # Crystal
                fish_indent.enable = true; # Fish
                hclfmt.enable = true; # HCL
                markdownlint.enable = true; # Markdown
                nixpkgs_fmt.enable = true; # Nix

                prettier = { enable = true; disableTsServerFormatter = true; };

                shellharden.enable = true; # Shell
                shfmt.enable = true; # Bash
                sqlfluff.enable = true; # SQL
                stylua.enable = true; # Lua
                tidy.enable = true; # HTML
              };

              hover = {
                dictionary.enable = true;
                printenv.enable = true;
              };
            };
          };

          nvim-autopairs = {
            enable = true;

            settings.check_ts = true;
          };

          cmp = {
            enable = true;

            settings = {
              #   mapping = {
              #     "<C-b>" = "cmp.mapping.scroll_docs(-4)";
              #     "<C-f>" = "cmp.mapping.scroll_docs(4)";
              #     "<C-e>" = "cmp.mapping.abort()";
              #     "<CR>" = "cmp.mapping.confirm({ select = false })";
              #
              #     "<Tab>" = {
              #       modes = [ "i" "s" ];
              #
              #       action = ''
              #         function(fallback)
              #           unpack = unpack or table.unpack
              #           local line, col = unpack(vim.api.nvim_win_get_cursor(0))
              #
              #           if cmp.visible() then
              #             cmp.select_next_item()
              #           else
              #             local _, err = pcall(function()
              #               if vim.fn["vsnip#available"](1) == 1 then
              #                 vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>(vsnip-expand-or-jump)", true, true, true), "", true)
              #               else
              #                 error({code=121})
              #               end
              #             end)
              #
              #             if err.code == 121 and col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil then
              #               cmp.complete()
              #             else
              #               fallback()
              #             end
              #           end
              #         end
              #       '';
              #     };
              #
              #     "<S-Tab>" = {
              #       modes = [ "i" "s" ];
              #
              #       action = ''
              #         function()
              #           if cmp.visible() then
              #             cmp.select_next_item()
              #           elseif vim.call('vsnip#jumpable', -1) == 1 then
              #             vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>(vsnip-jump-prev)", true, true, true), "", true)
              #           end
              #         end
              #       '';
              #     };
              #   };
              #
              #   # mappingPresets = [ "cmdline" ];
              view.entries = "native";
            };
          };

          nvim-colorizer.enable = true;

          rainbow-delimiters = {
            enable = true;

            highlight = charHighlightList;
          };

          surround.enable = true;
          telescope.enable = true; # TODO: Figure out how to fix
          todo-comments.enable = true;

          treesitter = {
            enable = true;

            indent = true;
          };

          treesitter-context.enable = true;
          ts-autotag.enable = true;
          ts-context-commentstring.enable = true;
        };
      };

    #   plugins = with pkgs.vimPlugins; [
    #     {
    #       plugin = impatient-nvim; # TODO: Add to nixvim
    #       type = "lua";
    #       config = "require('impatient')";
    #     }
    #     {
    #       plugin = scrollbar-nvim; # TODO: Add to nixvim
    #       config = ''
    #         augroup ScrollbarInit
    #           autocmd!
    #           autocmd WinScrolled,VimResized,QuitPre * silent! lua require('scrollbar').show()
    #           autocmd WinEnter,FocusGained * silent! lua require('scrollbar').show()
    #           autocmd WinLeave,BufLeave,BufWinLeave,FocusLost * silent! lua require('scrollbar').clear()
    #         augroup end
    #       '';
    #     }
    #     vim-eunuch
  };
}
