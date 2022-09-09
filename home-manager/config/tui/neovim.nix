{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    nvimpager
  ];

  home.sessionVariables = {
    "EDITOR" = "${config.programs.neovim.finalPackage}/bin/nvim";
    "PAGER" = "${pkgs.nvimpager}/bin/nvimpager";
    "VISUAL" = "${config.home.sessionVariables.EDITOR} -R";
  };

  programs.neovim = {
    enable = true;

    package = pkgs.nixpkgs-unstable.neovim-unwrapped;

    withNodeJs = true;

    extraConfig = ''
      " Enable filetype plugins
      filetype plugin indent on

      " Enable syntax
      syntax enable
      augroup FlakeLockFix
        autocmd BufNewFile,BufRead flake.lock set filetype=json
      augroup end

      " Allow line delete
      set whichwrap+=<,>,h,l

      " Set Editor information
      set colorcolumn=80
      set completeopt=menuone,noinsert,noselect,preview
      set cursorline
      set fileformats=unix,dos,mac
      set foldcolumn=1
      set guicursor=n-c-v-sm:block-nCursor
        \,i-ci-ve:ver25-iCursor
        \,r-cr-o:hor20-Cursor
        \,a:blinkwait300-blinkon200-blinkoff150
      set list
      set mouse=a
      set number
      set scrolloff=7
      set showmatch
      set showtabline=2
      set splitbelow
      set splitright
      set termguicolors
      set timeoutlen=500
      set title

      " Set Tab information
      set expandtab
      set linebreak
      set shiftwidth=4
      set smartindent
      set softtabstop=4
      set textwidth=500

      " Set Search Options
      set ignorecase
      set smartcase

      " Backup options (just use vcs instead)
      set noswapfile
      set nowritebackup

      " Provide better undo support
      set undofile

      " Remap some keys
      map <C-j> <C-W>j
      map <C-k> <C-W>k
      map <C-h> <C-W>h
      map <C-l> <C-W>l
      map 0 ^
    '';

    plugins = with pkgs.vimPlugins; [
      {
        plugin = ansible-vim;
        config = ''
          augroup ansible_vim_ftplaybooks
            autocmd!
            autocmd BufNewFile,BufRead */playbooks/*.yml setfiletype yaml.ansible
          augroup end
        '';
      }
      {
        plugin = barbar-nvim;
        type = "lua";
        config = ''
          local map = vim.api.nvim_set_keymap
          local opts = { noremap = true, silent = true }

          -- Move to previous/next
          map('n', '<A-,>', '<Cmd>BufferPrevious<CR>', opts)
          map('n', '<A-.>', '<Cmd>BufferNext<CR>', opts)

          -- Reordering to previous/next
          map('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', opts)
          map('n', '<A->>', '<Cmd>BufferMoveNext<CR>', opts)

          -- Go-to buffer in position
          map('n', '<A-1>', '<Cmd>BufferGoto 1<CR>', opts)
          map('n', '<A-2>', '<Cmd>BufferGoto 2<CR>', opts)
          map('n', '<A-3>', '<Cmd>BufferGoto 3<CR>', opts)
          map('n', '<A-4>', '<Cmd>BufferGoto 4<CR>', opts)
          map('n', '<A-5>', '<Cmd>BufferGoto 5<CR>', opts)
          map('n', '<A-6>', '<Cmd>BufferGoto 6<CR>', opts)
          map('n', '<A-7>', '<Cmd>BufferGoto 7<CR>', opts)
          map('n', '<A-8>', '<Cmd>BufferGoto 8<CR>', opts)
          map('n', '<A-9>', '<Cmd>BufferGoto 9<CR>', opts)
          map('n', '<A-0>', '<Cmd>BufferLast<CR>', opts)

          -- Pin/unpin buffer
          map('n', '<A-p>', '<Cmd>BufferPin<CR>', opts)

          -- Close buffer
          map('n', '<A-w>', '<Cmd>BufferClose<CR>', opts)
        '';

      }
      cmp-buffer
      cmp-nvim-lsp
      cmp-path
      cmp-treesitter
      cmp-vsnip
      {
        plugin = dashboard-nvim;
        config = "let g:dashboard_default_executive = 'telescope'";
      }
      editorconfig-nvim
      {
        plugin = formatter-nvim;
        type = "lua";
        config = ''
          require('formatter').setup({
            filetype = {
              javascript = {
                -- Prettier
                function()
                  return {
                    exe = "${pkgs.nodePackages.prettier}/bin/prettier",
                    args = {
                      "--stdin-filepath",
                      vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)),
                      "--single-quote"
                    },
                    stdin = true
                  }
                end
              },
              go = {
                -- gofumpt
                function()
                  return {
                    exe = "${pkgs.gofumpt}/bin/gofumpt",
                    args = {},
                    stdin = false,
                  }
                end
              },
              nix = {
                function()
                  return {
                    exe = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt",
                    args = {
                      "--"
                    },
                    stdin = true
                  }
                end
              },
              python = {
                -- Black
                function()
                  return {
                    exe = "${pkgs.python3Packages.black}/bin/black",
                    args = { '-' },
                    stdin = true,
                  }
                end
              },
              rust = {
                -- Rustfmt
                function()
                  return {
                    exe = "${pkgs.rustfmt}/bin/rustfmt",
                    args = {
                      "--emit=stdout"
                    },
                    stdin=true
                  }
                end
              },
              sh = {
                -- Shell script formatter
                function()
                  return {
                    exe = "${pkgs.shfmt}/bin/shfmt",
                    args = {
                      "-i",
                      "4"
                    },
                    stdin = true
                  }
                end
              },
              terraform = {
                function()
                  return {
                    exe = "${pkgs.terraform}/bin/terraform",
                    args = {
                      "fmt",
                      "-"
                    },
                    stdin = true
                  }
                end
              }
            }
          })
        '';
      }
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = "require('gitsigns').setup()";
      }
      {
        plugin = comment-nvim;
        type = "lua";
        config = ''
          require('Comment').setup({
            pre_hook = function(ctx)
              -- Only calculate commentstring for tsx filetypes
              if vim.bo.filetype == 'typescriptreact' then
                local U = require('Comment.utils')

                -- Determine whether to use linewise or blockwise commentstring
                local type = ctx.ctype == U.ctype.linewise and '__default' or '__multiline'

                -- Determine the location where to calculate commentstring from
                local location = nil
                if ctx.ctype == U.ctype.blockwise then
                  location = require('ts_context_commentstring.utils').get_cursor_location()
                elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
                  location = require('ts_context_commentstring.utils').get_visual_start_location()
                  end

                return require('ts_context_commentstring.internal').calculate_commentstring({
                  key = type,
                  location = location,
                })
              end
            end,
          })
        '';
      }
      lsp_signature-nvim
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require('lualine').setup({
            options = {
              icons_enabled = true,
              theme = 'nord',
            },
            sections = {
              lualine_a = {{'mode', upper = true}},
              lualine_b = {'branch'},
              lualine_c = {'diff', 'hostname', 'filename'},
              lualine_x = {'encoding', 'fileformat', 'filetype'},
              lualine_y = {'progress'},
              lualine_z = {'location'}
            }
          })
        '';
      }
      {
        plugin = nvim-autopairs;
        type = "lua";
        config = ''
          require('nvim-autopairs').setup({
            check_ts = true,
            ts_config = {
              lua = { "string", "source" },
              javascript = { "string", "template_string" },
              java = false,
            },
            disable_filetype = { "TelescopePrompt", "spectre_panel" },
            fast_wrap = {
              map = "<M-e>",
              chars = { "{", "[", "(", '"', "'" },
              pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
              offset = 0,
              end_key = "$",
              keys = "abcdefghijklmnopqrstuvwxyz",
              check_comma = true,
              highlight = "PmenuSel",
              highlight_grey = "LineNr",
            },
          })

          require('cmp').event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done { map_char = { tex = "" } })
        '';
      }
      {
        plugin = nvim-cmp;
        type = "lua";
        config = ''
          require('cmp').setup({
            snippet = {
              expand = function(args)
                vim.fn["vsnip#anonymous"](args.body)
              end
            },
            sources = {
              { name = 'nvim_lsp' },
              { name = 'vsnip' },
              { name = 'buffer' },
              { name = 'path' },
              { name = 'treesitter' }
            }
          })
        '';
      }
      {
        plugin = nvim-lint;
        type = "viml";
        config = ''
          lua << EOF
          require('lint').linters.ansible_lint.cmd = '${pkgs.ansible-lint}/bin/ansible-lint'
          require('lint').linters.cppcheck.cmd = '${pkgs.cppcheck}/bin/cppcheck'
          require('lint').linters.cspell.cmd = '${pkgs.nodePackages.cspell}/bin/cspell'
          require('lint').linters.flake8.cmd = '${pkgs.python3Packages.flake8}/bin/flake8'
          require('lint').linters.flawfinder.cmd = '${pkgs.flawfinder}/bin/flawfinder'
          require('lint').linters.nix.cmd = '${pkgs.nix}/bin/nix-instantiate'
          require('lint').linters.pylint.cmd = '${pkgs.python3Packages.pylint}/bin/pylint'
          require('lint').linters.shellcheck.cmd = '${pkgs.shellcheck}/bin/shellcheck'
          require('lint').linters.statix.cmd = '${pkgs.statix}/bin/statix'

          require('lint').linters_by_ft = {
            ada = {'cspell'},
            asciidoc = {'cspell'},
            c = {'flawfinder', 'cspell'},
            cpp = {'flawfinder', 'cppcheck', 'cspell'},
            go = {'cspell'},
            haskell = {'cspell'},
            java = {'cspell'},
            javascript = {'cspell'},
            json = {'cspell'},
            lua = {'cspell'},
            markdown = {'cspell'},
            nix = {'nix', 'statix'},
            python = {'pylint', 'flake8', 'cspell'},
            rst = {'cspell'},
            ruby = {'cspell'},
            rust = {'cspell'},
            sh = {'shellcheck', 'cspell'},
            tex = {'cspell'},
            text = {'cspell'},
            yaml = {'ansible_lint'}
          }
          EOF

          autocmd BufWritePost <buffer> lua require('lint').try_lint()
        '';
      }
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          local on_attach_func = function(client, bufnr)
              require('lsp_signature').on_attach({
                bind = true,
                handler_opts = {
                  border = "single"
                }
              }, bufnr)
          end

          local capabilities_var = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
          local runtime_path = vim.split(package.path, ';')
          table.insert(runtime_path, "lua/?.lua")
          table.insert(runtime_path, "lua/?/init.lua")

          local nvim_lsp = require('lspconfig')

          -- language-specific language-servers
          nvim_lsp.bashls.setup({
            capabilities = capabilities_var,
            cmd = {
              "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server",
              "start"
            },
            on_attach = on_attach_func
          })

          nvim_lsp.ccls.setup({
            capabilities = capabilities_var,
            cmd = { "${pkgs.ccls}/bin/ccls" },
            on_attach = on_attach_func
          })

          nvim_lsp.cssls.setup({
            capabilities = capabilities_var,
            cmd = {
              "${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-css-language-server",
              "--stdio"
            },
            on_attach = on_attach_func
          })

          nvim_lsp.dockerls.setup({
            capabilities = capabilities_var,
            cmd = {
              "${pkgs.nodePackages.dockerfile-language-server-nodejs}/bin/docker-langserver",
              "--stdio"
            },
            on_attach = on_attach_func
          })

          nvim_lsp.elixirls.setup({
            capabilities = capabilities_var,
            cmd = { "${pkgs.elixir_ls}/bin/elixir-ls" },
            on_attach = on_attach_func
          })

          nvim_lsp.erlangls.setup({
            capabilities = capabilities_var,
            cmd = { "${pkgs.erlang-ls}/bin/erlang_ls" },
            on_attach = on_attach_func
          })

          nvim_lsp.eslint.setup({
            capabilities = capabilities_var,
            cmd = {
              "${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-eslint-language-server",
              "--stdio"
            },
            on_attach = on_attach_func
          })

          nvim_lsp.gopls.setup({
            capabilities = capabilities_var,
            cmd = { "${pkgs.gopls}/bin/gopls" },
            on_attach = on_attach_func
          })

          nvim_lsp.html.setup({
            capabilities = capabilities_var,
            cmd = {
              "${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-html-language-server",
              "--stdio"
            },
            on_attach = on_attach_func
          })

          nvim_lsp.jsonls.setup({
            capabilities = capabilities_var,
            cmd = {
              "${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-json-language-server",
              "--stdio"
            },
            on_attach = on_attach_func
          })

          nvim_lsp.pylsp.setup({
            capabilities = capabilities_var,
            cmd = { "${pkgs.python3Packages.python-lsp-server}/bin/pylsp"},
            on_attach = on_attach_func
          })

          nvim_lsp.pyright.setup({
            capabilities = capabilities_var,
            cmd = {
              "${pkgs.pyright}/bin/pyright-langserver",
              "--stdio"
            },
            on_attach = on_attach_func
          })

          nvim_lsp.rnix.setup({
            capabilities = capabilities_var,
            cmd = { "${pkgs.rnix-lsp}/bin/rnix-lsp" },
            on_attach = on_attach_func
          })

          nvim_lsp.rust_analyzer.setup({
            capabilities = capabilities_var,
            cmd = { "${pkgs.rust-analyzer}/bin/rust-analyzer" },
            on_attach = on_attach_func
          })

          nvim_lsp.sqls.setup({
            capabilities = capabilities_var,
            cmd = { "${pkgs.sqls}/bin/sqls" },
            on_attach = on_attach_func
          })

          nvim_lsp.sumneko_lua.setup({
            capabilities = capabilities_var,
            cmd = {"${pkgs.sumneko-lua-language-server}/bin/lua-language-server"},
            on_attach = on_attach_func,
            settings = {
              Lua = {
                runtime = {
                  version = 'LuaJIT',
                  path = runtime_path,
                },
                diagnostics = {
                  globals = {'vim'},
                },
                workspace = {
                  library = vim.api.nvim_get_runtime_file("", true),
                }
              }
            }
          })

          nvim_lsp.terraformls.setup({
            capabilities = capabilities_var,
            cmd = {
              "${pkgs.terraform-ls}/bin/terraform-ls",
              "serve"
            },
            on_attach = on_attach_func
          })

          nvim_lsp.tsserver.setup({
            capabilities = capabilities_var,
            cmd = {
              "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server",
              "--stdio"
            },
            on_attach = on_attach_func
          })

          nvim_lsp.vimls.setup({
            capabilities = capabilities_var,
            cmd = {
              "${pkgs.nodePackages.vim-language-server}/bin/vim-language-server",
              "--stdio"
            },
            on_attach = on_attach_func
          })

          nvim_lsp.vuels.setup({
            capabilities = capabilities_var,
            cmd = { "${pkgs.nodePackages.vue-language-server}/bin/vls" },
            on_attach = on_attach_func
          })

          nvim_lsp.yamlls.setup({
            capabilities = capabilities_var,
            cmd = {
              "${pkgs.nodePackages.yaml-language-server}/bin/yaml-language-server",
              "--stdio"
            },
            on_attach = on_attach_func
          })
        '';
      }
      {
        plugin = nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars);
        type = "lua";
        config = ''
          require('nvim-treesitter.configs').setup({
            autopairs = {
              enable = true
            },
            autotag = {
              enable = true
            },
            context_commentstring = {
              enable = true,
              enable_autocmd = false,
            },
            highlight = {
              enable = true,
              additional_vim_regex_highlighting = false,
            },
            incremental_selection = {
              enable = true
            },
            indent = {
              enable = true
            },
            rainbow = {
              enable = true,
              extended_mode = true,
              max_file_lines = 2000
            },
            sync_install = false,
          })
        '';
      }
      nvim-ts-autotag
      nvim-ts-context-commentstring
      nvim-ts-rainbow
      nvim-web-devicons
      {
        plugin = nord-nvim;
        config = "colorscheme nord";
      }
      {
        plugin = scrollbar-nvim;
        config = ''
          augroup ScrollbarInit
            autocmd!
            autocmd WinScrolled,VimResized,QuitPre * silent! lua require('scrollbar').show()
            autocmd WinEnter,FocusGained * silent! lua require('scrollbar').show()
            autocmd WinLeave,BufLeave,BufWinLeave,FocusLost * silent! lua require('scrollbar').clear()
          augroup end
        '';
      }
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          require('telescope').setup({
            defaults = {
              vimgrep_arguments = {
                'rg',
                '--color=never',
                '--no-heading',
                '--with-filename',
                '--line-number',
                '--column',
                '--smart-case'
              },
              prompt_prefix = "> ",
              selection_caret = "> ",
              entry_prefix = " ",
              initial_mode = "insert",
              selection_strategy = "reset",
              sorting_strategy = "descending",
              layout_strategy = "horizontal",
              layout_config = {
                horizontal = {
                  mirror = false,
                },
                vertical = {
                  mirror = false,
                },
              },
              file_sorter = require'telescope.sorters'.get_fuzzy_file,
              file_ignore_patterns = {},
              eneric_sorter =  require'telescope.sorters'.get_generic_fuzzy_sorter,
              winblend = 0,
              border = {},
              borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
              color_devicons = true,
              use_less = true,
              set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
              file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
              grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
              qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,

              -- Developer configurations: Not meant for general override
              buffer_previewer_maker = require'telescope.previewers'.buffer_previewer_maker
            }
          })
        '';
      }
      {
        plugin = todo-comments-nvim;
        type = "lua";
        config = "require('todo-comments').setup()";
      }
      vim-eunuch
      vim-indent-guides
      vim-lastplace
      vim-nix
      vim-surround
      vim-vsnip
    ];
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
    # VSCode/VSCodium: https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig

    root = true

    # Set file defaults
    [*]
    end_of_line = lf
    insert_final_newline = true
    trim_trailing_whitespace = true
    indent_style = space
    indent_size = 4
    charset = utf-8

    [*.md]
    trim_trailing_whitespace = false

    [Makefile]
    indent_style = tab
    indent_size = 8

    # Default to two spaces for data languages
    [*.{c,cpp,css,h,hpp,htm,html,js,json,lua,nix,tf,ts,yml,yaml,xml,xhtml}]
    indent_style = space
    indent_size = 2

    [flake.lock]
    indent_style = space
    indent_size = 2
  '';
}
