{ config, lib, ... }:

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

        extraConfigLuaPost = vimHLString;
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

          comment-nvim.enable = true;
          dashboard.enable = true;
          emmet.enable = true;
          gitgutter.enable = true;

          indent-blankline = {
            # inherit charHighlightList;

            enable = true;

            showCurrentContext = true;
            showCurrentContextStart = true;
          };

          lastplace.enable = true;

          lsp = {
            enable = true;

            servers = {
              bashls.enable = true;
              clangd.enable = true;
              cssls.enable = true;
              elixirls.enable = true;
              eslint.enable = true;
              gopls.enable = true;
              hls.enable = true;
              html.enable = true;
              jsonls.enable = true;
              lua-ls.enable = true;
              nil_ls.enable = true;
              # pylsp.enable = true;
              pyright.enable = true;
              # rnix-lsp.enable = true;
              ruff-lsp.enable = true;
              rust-analyzer.enable = true;
              terraformls.enable = true;
              texlab.enable = true;
              tsserver.enable = true;
              typst-lsp.enable = true;
              vuels.enable = true;
              yamlls.enable = true;
              zls.enable = true;

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

              # vimls = mkLspPlugin {
              #   name = "Vim Language Server";
              #   packageSet = pkgs.nodePackages;
              #   package = "vim-language-server";
              #   moduleName = "vimls";
              #   defaultArgs = [ "--stdio" ];
              # };
            };
          };

          lsp-format.enable = true;

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

          neo-tree.enable = true;
          # nix.enable = true;

          none-ls = {
            enable = true;
            sources = {
              code_actions.shellcheck.enable = true;

              diagnostics = {
                cppcheck.enable = true;
                deadnix.enable = true;
                flake8.enable = true;
                gitlint.enable = true;
                shellcheck.enable = true;
                statix.enable = true;

                # ansible-lint
                # cspell
                # clippy
                # flawfinder
                # nix-instantiate
                # pylint
                # nix-lint
              };

              formatting = {
                alejandra.enable = true;
                black.enable = true;
                cbfmt.enable = true;
                fnlfmt.enable = true;
                fourmolu.enable = true;
                nixpkgs_fmt.enable = true;
                prettier.enable = true;
                shfmt.enable = true;
                stylua.enable = true;
                taplo.enable = true;

                # go fmt
                # gofumpt
                # rustfmt
                # terraform fmt
              };
            };
          };

          nvim-autopairs = {
            enable = true;

            checkTs = true;
          };

          nvim-cmp = {
            enable = true;

            mapping = {
              "<C-b>" = "cmp.mapping.scroll_docs(-4)";
              "<C-f>" = "cmp.mapping.scroll_docs(4)";
              "<C-e>" = "cmp.mapping.abort()";
              "<CR>" = "cmp.mapping.confirm({ select = false })";

              "<Tab>" = {
                modes = [ "i" "s" ];

                action = ''
                  function(fallback)
                    unpack = unpack or table.unpack
                    local line, col = unpack(vim.api.nvim_win_get_cursor(0))

                    if cmp.visible() then
                      cmp.select_next_item()
                    else
                      local _, err = pcall(function()
                        if vim.fn["vsnip#available"](1) == 1 then
                          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>(vsnip-expand-or-jump)", true, true, true), "", true)
                        else
                          error({code=121})
                        end
                      end)

                      if err.code == 121 and col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil then
                        cmp.complete()
                      else
                        fallback()
                      end
                    end
                  end
                '';
              };

              "<S-Tab>" = {
                modes = [ "i" "s" ];

                action = ''
                  function()
                    if cmp.visible() then
                      cmp.select_next_item()
                    elseif vim.call('vsnip#jumpable', -1) == 1 then
                      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Plug>(vsnip-jump-prev)", true, true, true), "", true)
                    end
                  end
                '';
              };
            };

            mappingPresets = [ "cmdline" ];
            snippet.expand = "vsnip";

            sources = [
              { name = "nvim_lsp"; }
              { name = "nvim_lsp_document_symbol"; }
              { name = "nvim_lsp_signature_help"; }
              { name = "vsnip"; }
              { name = "treesitter"; }
              { name = "buffer"; }
              { name = "pandoc_references"; }
              { name = "git"; }
              { name = "path"; }
              { name = "cmdline"; }
              { name = "cmp-cmdline-history"; }
              { name = "spell"; }
              { name = "calc"; }
            ];

            view.entries = "native";
          };

          nvim-colorizer.enable = true;
          surround.enable = true;
          telescope.enable = true; # TODO: Figure out how to fix
          todo-comments.enable = true;

          treesitter = {
            enable = true;

            indent = true;
          };

          treesitter-context.enable = true;

          rainbow-delimiters = {
            enable = true;

            highlight = charHighlightList;
          };

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
