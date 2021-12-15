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

      lua require('plugins')
    '';
  };

  xdg.configFile."nvim/lua" = {
    source = ./../../../home/.config/nvim/lua;
    recursive = true;
  };

}
