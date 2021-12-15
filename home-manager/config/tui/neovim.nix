{ config, pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    # Language servers
    ccls
    elixir_ls
    erlang-ls
    gopls
    go-langserver
    haskellPackages.haskell-language-server
    nodePackages.bash-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.typescript-language-server
    nodePackages.vim-language-server
    nodePackages.vue-language-server
    nodePackages.yaml-language-server
    python39Packages.python-lsp-server
    python39Packages.python-lsp-black
    rnix-lsp
    rust-analyzer
    sumneko-lua-language-server
    terraform-ls

    # Linters
    ansible-lint
    shellcheck
    cppcheck
    flawfinder
    nodePackages.cspell
    statix

    # Formatters
    astyle
    black
    gofumpt
    jq
    nodePackages.prettier
    nixpkgs-fmt
    rustfmt
    shfmt

    # Plugin tools
    code-minimap
    libtool
    tree-sitter
  ];

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
      ansible-vim
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
              rust = {
                -- Rustfmt
                function()
                  return {
                    exe = "rustfmt",
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
                    exe = "shfmt",
                    args = {
                      "-i",
                      "4"
                    },
                    stdin = true
                  }
                end
              },
              nix = {
                function()
                  return {
                    exe = "nixpkgs-fmt",
                    args = {
                      "--"
                    },
                    stdin = true
                  }
                end
              },
              terraform = {
                function()
                  return {
                    exe = "terraform",
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
      {
        plugin = lualine-nvim;
        config = ''
          lua << EOF
          require('lualine').setup{
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
          }
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
          require('cmp').setup{
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
          }
          EOF
        '';
      }
      {
        plugin = nvim-lint;
        config = ''
          lua << EOF
          require('lint').linters_by_ft = {
            ada = {'cspell'},
            asciidoc = {'cspell'},
            c = {'flawfinder', 'cspell'},
            cpp = {'flawfinder', 'cspell'},
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
            text = {'cspell'}
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
          nvim_lsp.ansiblels.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.bashls.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.ccls.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.cssls.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.dockerls.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.elixirls.setup{
            capabilities=capabilities_var,
            cmd = { "elixir-ls" },
            on_attach=on_attach_func
          }

          nvim_lsp.erlangls.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.gopls.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.hls.setup{
            capabilities=capabilities_var,
            cmd = {
              "haskell-language-server",
              "lsp"
            },
            on_attach=on_attach_func
          }

          nvim_lsp.html.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.jsonls.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.pylsp.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.pyright.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.rnix.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.rust_analyzer.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.sqls.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.stylelint_lsp.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.sumneko_lua.setup{
            capabilities=capabilities_var,
            cmd = {"lua-language-server"},
            on_attach=on_attach_func,
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
          }

          nvim_lsp.terraformls.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.vimls.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.vuels.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }

          nvim_lsp.yamlls.setup{
            capabilities=capabilities_var,
            on_attach=on_attach_func
          }
          EOF
        '';
      }
      {
        plugin = nvim-treesitter;
        config = ''
          lua << EOF
          require('nvim-treesitter.configs').setup{
            ensure_installed = "all",
            highlight = {
              enable = true,
            },
            rainbow = {
              enable = true,
              extended_mode = true,
              max_file_lines = 2000
            }
          }
          EOF
        '';
      }
      nvim-ts-rainbow
      nvim-web-devicons
      {
        plugin = nord-nvim;
        config = "colorscheme nord";
      }
      plenary-nvim
      popup-nvim
      {
        plugin = telescope-nvim;
        config = ''
          lua << EOF
          require('telescope').setup{
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
          }
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

}
