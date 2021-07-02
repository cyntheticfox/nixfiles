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
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require'treesitter_config'
    end
  }

  -- Utility
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
    'glepnir/dashboard.nvim',
    config = function()
      vim.g.dashboard_default_executive='telescope'
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
  use {
    "blackCauldron7/surround.nvim",
    config = function()
      require "surround".setup{}
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
    'Th3Whit3Wolf/one-nvim',
    config = function()
      vim.cmd [[colorscheme one-nvim]]
      vim.g.one_nvim_transparent_bg = true
    end
  }

  -- Vim plugins
  use 'LnL7/vim-nix'
  use 'editorconfig/editorconfig-vim'
  use 'jiangmiao/auto-pairs'
  use 'lilyinstarlight/vim-resolve'
  use 'lilyinstarlight/vim-spl'
  use 'tpope/vim-eunuch'
end)
