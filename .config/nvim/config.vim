" Enable filetype plugins
filetype plugin on
filetype indent on

" Allow autoread for outside file changes
set autoread

" Allow line delete
set backspace=indent,eol,start
set whichwrap+=<,>,h,l

" Set Editor information
set termguicolors
set scrolloff=7
set number
syntax on
set cursorline
set ruler
set nostartofline
set laststatus=2
set mouse=a
set nolazyredraw
set magic
set showmatch
set foldcolumn=1
set encoding=utf8
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
