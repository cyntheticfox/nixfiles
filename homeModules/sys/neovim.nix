{ config, pkgs, lib, ... }:

let
  cfg = config.sys.neovim;

  genHLList = prefix: list:
    let
      vimHLList = lib.zipListsWith (a: b: "highlight ${prefix}${builtins.toString a} guifg=${b} gui=nocombine") (builtins.genList (x: x) (builtins.length list)) list;
      mkLines = builtins.concatStringsSep "\n";
    in
    {
      inherit vimHLList;

      hlGroupList = builtins.map (x: "${prefix}${builtins.toString x}") (builtins.genList (x: x) (builtins.length list));
      vimHLString = mkLines vimHLList;
      luaVimCmdHLString = mkLines (builtins.map (x: "vim.cmd [[${x}]]") vimHLList);
    };

  genLuaList = list:
    "{ ${builtins.concatStringsSep ", " (builtins.map (x: "\"${x}\"") list)} }";
in
{
  options.sys.neovim = {
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

    plugins.treesitter = {
      enable = lib.mkEnableOption "Enable Treesitter support" // { default = true; };

      package = lib.mkPackageOption pkgs "vimPlugins.nvim-treesitter" { default = pkgs.vimPlugins.nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars); };
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      "EDITOR" = "${config.programs.neovim.finalPackage}/bin/nvim";
      "VISUAL" = "${config.programs.neovim.finalPackage}/bin/nvim -R";
    };

    home.shellAliases = {
      "vdiff" = "nvim -d";
      "vsplit" = "nvim -O2"; # Kinda wish I could just change the default behavior instead of this
      "vsudo" = "sudo -- nvim -u ~/.config/nvim/init.vim";
    };

    programs.neovim = {
      enable = true;

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
        set completeopt=menu,menuone,noinsert,noselect,preview
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
        set termguicolors
        set timeoutlen=500
        set title

        " Set reasonable split behavior
        set splitbelow
        set splitright

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

        " Set up leader mappings
        nnoremap <leader>et :tabe<CR>
        nnoremap <leader>w :set wrap! wrap?<CR>

        " Easier buffer switching
        nnoremap <leader>h <C-w>h
        nnoremap <leader>j <C-w>j
        nnoremap <leader>k <C-w>k
        nnoremap <leader>l <C-w>l

        " Easier terminal launch
        nnoremap <silent> <leader>tt :terminal<CR>
        nnoremap <silent> <leader>tv :vnew<CR>:terminal<CR>
        nnoremap <silent> <leader>th :new<CR>:terminal<CR>

        " Teminal mappings
        tnoremap <C-x> <C-\><C-n><C-w>q
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
        cmp-git
        cmp-nvim-lsp
        cmp-path
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
                      exe = "${lib.getExe pkgs.nodePackages.prettier}",
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
                      exe = "${lib.getExe pkgs.gofumpt}",
                      args = {},
                      stdin = false,
                    }
                  end
                },
                nix = {
                  function()
                    return {
                      exe = "${lib.getExe pkgs.nixpkgs-fmt}",
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
                      exe = "${lib.getExe pkgs.python3Packages.black}",
                      args = { '-' },
                      stdin = true,
                    }
                  end
                },
                rust = {
                  -- Rustfmt
                  function()
                    return {
                      exe = "${lib.getExe pkgs.rustfmt}",
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
                      exe = "${lib.getExe pkgs.shfmt}",
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
                      exe = "${lib.getExe pkgs.terraform}",
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
          plugin = impatient-nvim;
          type = "lua";
          config = "require('impatient')";
        }
        {
          plugin = indent-blankline-nvim-lua;
          type = "lua";
          config =
            let
              hlList = genHLList "IndentBlanklineIndent" cfg.colorlist;
            in
            ''
              ${hlList.luaVimCmdHLString}

              require('indent_blankline').setup {
                show_current_context = true,
                show_current_context_start = true,
                char_highlight_list = ${genLuaList hlList.hlGroupList}
              }
            '';
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
            local has_words_before = function()
              local line, col = unpack(vim.api.nvim_win_get_cursor(0))
              return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
            end

            local feedkey = function(key, mode)
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
            end

            local cmp = require('cmp')

            cmp.setup({
              enabled = function()
                local context = require('cmp.config.context')
                if vim.api.nvim_get_mode == 'c' then
                  return true
                else
                ${ if cfg.plugins.treesitter.enable then
                  "return not context.in_treesitter_capture('Comment') and not context.in_syntax_group('Comment')" else "return not context.in_syntax_group('Comment')" }
                end
              end,
              snippet = {
                expand = function(args)
                  vim.fn["vsnip#anonymous"](args.body)
                end
              },
              window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
              },
              mapping = cmp.mapping.preset.insert({
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                --['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = false }),
                ['<Tab>'] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  elseif vim.fn['vsnip#available'](1) == 1 then
                    feedkey("<Plug>(vsnip-expand-or-jump)", "")
                  elseif has_words_before() then
                    cmp.complete()
                  else
                    fallback()
                  end
                end, { 'i', 's'}),
                ['<S-Tab'] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_prev_item()
                  elseif vim.fn['vsnip#jumpable'](-1) == 1 then
                    feedkey("<Plug>(vsnip-jump-prev)", "")
                  else
                    fallback()
                  end
                end, { 'i', 's' }),
              }),
              sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'vsnip' },
                { name = 'path' },
                ${ lib.optionalString cfg.plugins.treesitter.enable "{ name = 'treesitter' },"}
              }, {
                { name = 'buffer' },
              }),
            })

            -- Configure gitcommit filetype
            -- cmp.setup.filetype('gitcommit', {
            --   sources = cmp.config.sources({
            --     { name = 'cmp_git' },

            --   }, {
            --     { name = 'buffer' },
            --   })
            -- })

            -- Use 'buffer' source for nvim search mode
            cmp.setup.cmdline('/', {
              mapping = cmp.mapping.preset.cmdline(),
              sources = {
                { name = 'buffer' }
              }
            })

            -- Use 'cmdline' & 'path' source for nvim command mode
            cmp.setup.cmdline(':', {
              mapping = cmp.mapping.preset.cmdline(),
              sources = cmp.config.sources({
                { name = 'path' }
              }, {
                { name = 'cmdline' }
              })
            })
          '';
        }
        {
          plugin = nvim-lint;
          type = "viml";
          config = ''
            lua << EOF
            require('lint').linters.ansible_lint.cmd = '${lib.getExe pkgs.ansible-lint}'
            require('lint').linters.cppcheck.cmd = '${lib.getExe pkgs.cppcheck}'
            require('lint').linters.cspell.cmd = '${lib.getExe pkgs.nodePackages.cspell}'
            require('lint').linters.flake8.cmd = '${lib.getExe pkgs.python3Packages.flake8}'
            require('lint').linters.flawfinder.cmd = '${lib.getExe pkgs.flawfinder}'
            require('lint').linters.nix.cmd = '${pkgs.nix}/bin/nix-instantiate'
            require('lint').linters.pylint.cmd = '${lib.getExe pkgs.python3Packages.pylint}'
            require('lint').linters.shellcheck.cmd = '${lib.getExe pkgs.shellcheck}'
            require('lint').linters.statix.cmd = '${lib.getExe pkgs.statix}'

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

            local capabilities_var = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
            local runtime_path = vim.split(package.path, ';')
            table.insert(runtime_path, "lua/?.lua")
            table.insert(runtime_path, "lua/?/init.lua")

            local nvim_lsp = require('lspconfig')

            -- language-specific language-servers
            nvim_lsp.bashls.setup({
              capabilities = capabilities_var,
              cmd = {
                "${lib.getExe pkgs.nodePackages.bash-language-server}",
                "start"
              },
              on_attach = on_attach_func
            })

            nvim_lsp.ccls.setup({
              capabilities = capabilities_var,
              cmd = { "${lib.getExe pkgs.ccls}" },
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
              cmd = { "${lib.getExe pkgs.gopls}" },
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
              cmd = { "${lib.getExe pkgs.rnix-lsp}" },
              on_attach = on_attach_func
            })

            nvim_lsp.rust_analyzer.setup({
              capabilities = capabilities_var,
              cmd = { "${lib.getExe pkgs.rust-analyzer}" },
              on_attach = on_attach_func
            })

            nvim_lsp.sqls.setup({
              capabilities = capabilities_var,
              cmd = { "${lib.getExe pkgs.sqls}" },
              on_attach = on_attach_func
            })

            nvim_lsp.sumneko_lua.setup({
              capabilities = capabilities_var,
              cmd = {"${lib.getExe pkgs.sumneko-lua-language-server}"},
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
                "${lib.getExe pkgs.terraform-ls}",
                "serve"
              },
              on_attach = on_attach_func
            })

            nvim_lsp.tsserver.setup({
              capabilities = capabilities_var,
              cmd = {
                "${lib.getExe pkgs.nodePackages.typescript-language-server}",
                "--stdio"
              },
              on_attach = on_attach_func
            })

            nvim_lsp.vimls.setup({
              capabilities = capabilities_var,
              cmd = {
                "${lib.getExe pkgs.nodePackages.vim-language-server}",
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
                "${lib.getExe pkgs.nodePackages.yaml-language-server}",
                "--stdio"
              },
              on_attach = on_attach_func
            })
          '';
        }
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
        vim-gitgutter
        vim-lastplace
        vim-nix
        vim-surround
        vim-vsnip
      ] ++ lib.optionals cfg.plugins.treesitter.enable [
        cmp-treesitter
        {
          plugin = cfg.plugins.treesitter.package;
          type = "lua";
          config = ''
            require('nvim-treesitter.configs').setup({
              auto_install = false,
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
                max_file_lines = 2000,
                colors = ${genLuaList cfg.colorlist}
              },
              sync_install = false,
            })
          '';
        }
        {
          plugin = nvim-treesitter-context;
          type = "lua";
          config = ''
            require('treesitter-context').setup({
              enable = true,
              max_lines = 0,
              trim_scope = 'outer',
              min_window_height = 0,
              patterns = {
                -- For all filetypes
                default = {
                  'class',
                  'function',
                  'method',
                  'for',
                  'while',
                  'if',
                  'switch',
                  'case',
                },

                -- Patterns for specific filetypes
                tex = {
                  'chapter',
                  'section',
                  'subsection',
                  'subsubsection',
                },
                rust = {
                  'impl_item',
                  'struct',
                  'enum'
                },
                scala = {
                  'object_definition',
                },
                vhdl = {
                  'process_statement',
                  'architecture_body',
                  'entity_declaration',
                },
                markdown = {
                  'section',
                },
                elixir = {
                  'anonymous_function',
                  'arguments',
                  'block',
                  'do_block',
                  'list',
                  'map',
                  'tuple',
                  'quoted_content',
                },
                json = {
                  'pair',
                },
                yaml = {
                  'block_mapping_pair',
                },
              },
            })
          '';
        }
        nvim-ts-autotag
        nvim-ts-context-commentstring
        nvim-ts-rainbow
      ];
    };
  };
}
