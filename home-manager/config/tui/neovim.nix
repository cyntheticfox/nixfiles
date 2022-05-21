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

    withPython3 = true;
    withRuby = true;
    withNodeJs = true;

    extraConfig = ''
      " Enable filetype plugins
      if has('autocmd')
          filetype plugin indent on
      endif

      " Enable syntax
      if has('syntax')
          syntax enable
          if has('autocmd')
              autocmd BufNewFile,BufRead flake.lock set filetype=json
          endif
      endif

      " Allow autoread for outside file changes
      set autoread

      " Allow line delete
      set backspace=indent,eol,start
      set whichwrap+=<,>,h,l

      " Set Editor information
      set termguicolors
      set sessionoptions-=options
      set viewoptions-=options
      set display+=lastline
      set scrolloff=7
      set number
      set cursorline
      set ruler
      set nostartofline
      set laststatus=2
      set mouse=a
      set nolazyredraw
      set magic
      set showmatch
      set foldcolumn=1
      set encoding=utf-8
      set fileformats=unix,dos,mac
      set showtabline=2
      set ttyfast
      set completeopt=menuone,noinsert,noselect
      set guicursor=n-c-v-sm:block-nCursor-blinkwait300-blinkon200-blinkoff150

      " turn off sounds on errors
      set noerrorbells
      set novisualbell
      set t_vb=
      set timeoutlen=500

      " Set Tab information
      set autoindent
      set smartindent
      set wrap
      set expandtab
      set softtabstop=4
      set shiftwidth=4
      set linebreak
      set textwidth=500

      " Set Search Options
      set incsearch
      set hlsearch
      set ignorecase
      set smartcase

      set history=2000

      " Backup options (just use vcs instead)
      set nobackup
      set nowritebackup
      set noswapfile

      " Improve command-line completion
      set wildmenu

      " Add column ruler
      set colorcolumn=80

      " Remap some keys
      map <space> /
      map <C-space> ?
      map <C-j> <C-W>j
      map <C-k> <C-W>k
      map <C-h> <C-W>h
      map <C-l> <C-W>l
      map 0 ^
      nmap <M-j> mz:m+<cr>`z
      nmap <M-k> mz:m-2<cr>`z
      vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
      vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z
    '';

    plugins = with pkgs.vimPlugins; [
      {
        plugin = ansible-vim;
        config = ''
          augroup ansible_vim_ftplaybooks
            autocmd!
            autocmd BufNewFile,BufRead */playbooks/*.yml setfiletype yaml.ansible
          augroup END
        '';
      }
      barbar-nvim
      cmp-buffer
      cmp-nvim-lsp
      cmp-path
      cmp-treesitter
      cmp-vsnip
      {
        plugin = dashboard-nvim;
        config = "let g:dashboard_default_executive = 'telescope'";
      }
      editorconfig-vim
      {
        plugin = formatter-nvim;
        config = ''
          lua << EOF
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
          EOF
        '';
      }
      {
        plugin = gitsigns-nvim;
        config = "lua require('gitsigns').setup()";
      }
      kommentary
      lsp_signature-nvim
      {
        plugin = lualine-nvim;
        config = ''
          lua << EOF
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
          EOF
        '';
      }
      {
        plugin = minimap-vim;
        config = ''
          let g:minimap_width = 10
          let g:minimap_auto_start = 1
          let g:minimap_auto_start_win_enter = 1
          let g:minimap_git_colors = 1
          let g:minimap_search_color = 1
        '';
      }
      {
        plugin = nvim-autopairs;
        config = "lua require('nvim-autopairs').setup()";
      }
      {
        plugin = nvim-cmp;
        config = ''
          lua << EOF
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
          EOF
        '';
      }
      {
        plugin = nvim-lint;
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
        config = ''
          lua << EOF
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
          EOF
        '';
      }
      {
        plugin = nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars);
        config = ''
          lua << EOF
          require('nvim-treesitter.configs').setup({
            ensure_installed = "all",
            highlight = {
              enable = true,
            },
            rainbow = {
              enable = true,
              extended_mode = true,
              max_file_lines = 2000
            }
          })
          EOF
        '';
      }
      nvim-ts-rainbow
      nvim-web-devicons
      {
        plugin = nord-nvim;
        config = "colorscheme nord";
      }
      {
        plugin = telescope-nvim;
        config = ''
          lua << EOF
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
          EOF
        '';
      }
      {
        plugin = todo-comments-nvim;
        config = "lua require('todo-comments').setup()";
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
