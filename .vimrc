" This file will need to be renamed to ".vimrc" before use

" Disable vi support
set nocompatible

" Enable filetype plugins
filetype plugin on
filetype indent on

" Allow autoread for outside file changes
set autoread
au Focusgained,BufEnter * checktime

" Add handler for Capital W to be sudo save
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

" Allow line delete
set backspace=indent,eol,start
set whichwrap+=<,>,h,l

" Set Editor information
set so=7
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
set ffs=unix,dos,mac
set showtabline=2
set ttyfast

" turn off sounds on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Set Tab information
set autoindent
set smartindent
set wrap
set expandtab
set softtabstop=4
set shiftwidth=4
set lbr
set tw=500

" Set Search Options
set incsearch
set hlsearch
set ignorecase
set smartcase

set history=2000

" Backup options (just use vcs instead)
set nobackup
set nowb
set noswapfile

" Improve command-line completion
set wildmenu

" Add column ruler
set colorcolumn=80

" Set keymaps
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

if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'LnL7/vim-nix'
Plug 'NovaDev94/vim-fish'
Plug 'airblade/vim-gitgutter'
Plug 'cespare/vim-toml'
Plug 'editorconfig/editorconfig-vim'
Plug 'farmergreg/vim-lastplace'
Plug 'fidian/hexmode'
Plug 'fkmclane/vim-resolve'
Plug 'fkmclane/vim-spl'
Plug 'gisraptor/vim-lilypond-integrator'
Plug 'glts/vim-radical'
Plug 'junegunn/vim-plug'
Plug 'mattn/emmet-vim'
Plug 'mhinz/vim-startify'
Plug 'pearofducks/ansible-vim'
Plug 'PProvost/vim-ps1'
Plug 'ryanoasis/vim-devicons'
Plug 'tomasiser/vim-code-dark'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-crystal/vim-crystal'
Plug 'vim-syntastic/syntastic'

call plug#end()

" Set colorschemes
set background=dark
set guifont="FiraCode NF":h11
set renderoptions=type:directx,gamma:1.5,contrast:0.5,geom:1,renmode:5,taamode:1,level:0.5
colorscheme codedark

" Enable Tabline
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#alt_sep = 1

let g:airline_theme = 'codedark'
