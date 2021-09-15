require('packer_bootstrap')

return require('packer').startup(function()
  use 'wbthomason/packer.nvim'

  use {
    'neovim/nvim-lspconfig',
    config = function()
      require'lsp_config'
    end,
    requires = {
      'nvim-lua/completion-nvim'
    }
  }

  use {
    'ray-x/lsp_signature.nvim'
  }

  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require'treesitter_config'
    end,
    requires = {
      'p00f/nvim-ts-rainbow'
    }
  }

  -- Utility
  use {
    'folke/todo-comments.nvim',
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      require('todo-comments').setup {
      }
    end
  }
  use 'b3nj5m1n/kommentary'
  use {
    'ethanholz/nvim-lastplace',
    config = function()
      require'nvim-lastplace'.setup {
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
      require('gitsigns').setup{}
    end
  }
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      {'nvim-lua/popup.nvim'},
      {'nvim-lua/plenary.nvim'}
    },
    config = function()
      require'telescope_config'
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
      require'statusline_config'
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
  use 'jiangmiao/auto-pairs'
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
