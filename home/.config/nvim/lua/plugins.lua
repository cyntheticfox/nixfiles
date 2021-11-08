require('packer_bootstrap')

return require('packer').startup(function()
  use 'wbthomason/packer.nvim'

  use {
    'neovim/nvim-lspconfig',
    config = function()
      require('lsp_config')
    end,
    requires = {
      {
        'hrsh7th/nvim-cmp',
        config = function()
          require('cmp').setup{
            snippet = {
              expand = function(args)
                vim.fn["vsnip#anonymous"](args.body)
              end
            },
            sources = {
              { name = 'nvim_lsp' },
              { name = 'vsnip' },
              { name = 'buffer'},
              { name = 'path' },
              { name = 'treesitter'}
            }
          }
        end,
        requires = {
          'hrsh7th/cmp-nvim-lsp',
          'hrsh7th/cmp-path',
          'hrsh7th/cmp-buffer',
          'hrsh7th/cmp-vsnip',
          'hrsh7th/vim-vsnip',
          'ray-x/cmp-treesitter',
          {
            'dcampos/cmp-snippy',
            requires = {
              'dcampos/nvim-snippy',
              'honza/vim-snippets'
            }
          }
        }
      }
    }
  }

  use {
    'mfussenegger/nvim-lint',
    config = function()
      require('lint').linters_by_ft = {
        c = {'flawfinder'},
        nix = {'nix', 'statix'},
        sh = {'shellcheck'}
      }

      vim.cmd [[autocmd BufWritePost <buffer> lua require('lint').try_lint()]]
    end
  }

  use 'ray-x/lsp_signature.nvim'

  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require('treesitter_config')
    end,
    requires = {
      'p00f/nvim-ts-rainbow',
      {
        'windwp/nvim-ts-autotag',
        config = function()
          require('nvim-ts-autotag').setup()
        end
      },
      {
        'lewis6991/spellsitter.nvim',
        config = function()
          require('spellsitter').setup()
        end
      }
    }
  }

  -- Utility
  use 'b3nj5m1n/kommentary'
  use {
    'folke/todo-comments.nvim',
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      require('todo-comments').setup()
    end
  }
  use {
    'glepnir/indent-guides.nvim',
    config = function()
      require('indent_guides').setup()
    end
  }
  use {
    'mhartington/formatter.nvim',
    config = function()
      require('formatter_config')
    end
  }

  use {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup()
    end
  }
  use {
    'ethanholz/nvim-lastplace',
    config = function()
      require('nvim-lastplace').setup {
        lastplace_ignore_buftype = {
          "quickfix",
          "nofile",
          "help"
        },
        lastplace_ignore_filetype = {
          "gitcommit",
          "gitrebase",
          "svn",
          "hgcommit"
        },
        lastplace_open_folds = true
      }
    end
  }
  use {
    'jghauser/mkdir.nvim',
    config = function()
      require('mkdir')
    end
  }
  use {
    'lewis6991/gitsigns.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require('gitsigns').setup()
    end
  }
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      {'nvim-lua/popup.nvim'},
      {'nvim-lua/plenary.nvim'}
    },
    config = function()
      require('telescope_config')
    end
  }

  -- Tabline
  use {
    'romgrk/barbar.nvim',
    requires = {
      'kyazdani42/nvim-web-devicons'
    }
  }

  -- Statusline
  use {
    'hoob3rt/lualine.nvim',
    requires = {
      'kyazdani42/nvim-web-devicons'
    },
    config = function()
      require('statusline_config')
    end
  }

  -- Theme
  use {
    'navarasu/onedark.nvim',
    config = function()
      require('onedark').setup()
      vim.cmd [[colorscheme onedark]]
    end
  }

  -- Start page
  use {
    'glepnir/dashboard-nvim',
    config = function()
      vim.g.dashboard_default_executive = 'telescope'
    end
  }

  -- Vim plugins
  use 'LnL7/vim-nix'
  use 'editorconfig/editorconfig-vim'
  use 'lilyinstarlight/vim-resolve'
  use 'lilyinstarlight/vim-spl'
  --use 'mhinz/vim-startify'
  use 'pearofducks/ansible-vim'
  use 'tpope/vim-eunuch'
  use 'tpope/vim-surround'
  use {
    'wfxr/minimap.vim',
    config = function()
      vim.g.minimap_width = 10
      vim.g.minimap_auto_start = 1
      vim.g.minimap_auto_start_win_enter = 1
      vim.g.minimap_git_colors = 1
      vim.g.minimap_search_color = 1
    end
  }
end)
