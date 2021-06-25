" This file will need to be renamed to ".vimrc" before use

" Enable filetype plugins
filetype plugin on
filetype indent on

" Allow autoread for outside file changes
set autoread

" Allow line delete
set backspace=indent,eol,start
set whichwrap+=<,>,h,l

" Set Editor information
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

augroup VimPlug
    if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
        silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif
augroup END

" Required pre-set ALE options
let g:ale_cursor_detail = 0
let g:ale_echo_cursor = 1

call plug#begin('~/.local/share/nvim/site/plugged')

" Dependencies
Plug 'kyazdani42/nvim-web-devicons'
Plug 'nvim-lua/plenary.nvim'

" Neovim LSP plugins
Plug 'neovim/nvim-lspconfig'
Plug 'simrat39/rust-tools.nvim'

" Neovim Syntax
Plug 'nvim-treesitter/nvim-treesitter', {'do', ':TSUpdate'}

# Neovim Utility
Plug 'b3nj5m1n/kommentary'
Plug 'ethanholz/nvim-lastplace'
Plug 'jghauser/mkdir.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'steelsojka/pears.nvim'

" Neovim Theming
Plug 'romainl/Apprentice', { 'branch': 'fancylines-and-neovim' }

" Neovim Tabline
Plug 'romgrk/barbar.nvim'

" Neovim Statusline
Plug 'glepnir/galaxyline.nvim', {'branch': 'main'}

" Neovim Cursorline
Plug 'yamatsum/nvim-cursorline'

" Standard Vim plugins
"Plug 'LnL7/vim-nix'
"Plug 'NovaDev94/vim-fish'
"Plug 'airblade/vim-gitgutter'
"Plug 'cespare/vim-toml'
Plug 'dense-analysis/ale'
Plug 'editorconfig/editorconfig-vim'
"Plug 'farmergreg/vim-lastplace'
"Plug 'fidian/hexmode'
"Plug 'gisraptor/vim-lilypond-integrator'
"Plug 'glts/vim-radical'
Plug 'hashivim/vim-terraform'
"Plug 'jiangmiao/auto-pairs'
"Plug 'junegunn/vim-plug'
"Plug 'leafgarland/typescript-vim'
"Plug 'lervag/vimtex'
Plug 'lilyinstarlight/vim-resolve'
Plug 'lilyinstarlight/vim-spl'
Plug 'mattn/emmet-vim'
Plug 'mhinz/vim-startify'
Plug 'pearofducks/ansible-vim'
Plug 'PProvost/vim-ps1'
"Plug 'ryanoasis/vim-devicons'
"Plug 'rust-lang/rust.vim'
"Plug 'tmux-plugins/vim-tmux'
"Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
"Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
Plug 'vim-crystal/vim-crystal'
"Plug 'vim-syntastic/syntastic'
"Plug 'vimsence/vimsence'

call plug#end()

" Set colorschemes
colorscheme apprentice

" Enable Tabline
" let g:airline#extensions#tabline#enabled = 1
" let g:airline_powerline_fonts = 1
" let g:airline#extensions#tabline#alt_sep = 1
" let g:airline#extensions#ale#enabled = 1

" let g:airline_theme = 'apprentice'

" Enable vim-terraform options
let g:terraform_fmt_on_save = 1

" Enable ALE options
let g:ale_cache_executable_check_failures = 1
let g:ale_change_sing_column_color = 1
let g:ale_close_preview_on_insert = 1
let g:ale_completion_enabled = 1
let g:ale_completion_autoimport = 1
let g:ale_linter_aliases = {
\    'Dockerfile': 'dockerfile',
\    'csh': 'sh',
\    'javascriptreact': ['javascript', 'jsx'],
\    'ps1': 'powershell',
\    'systemverilog': 'verilog',
\    'vimwiki': 'markdown',
\    'vue': ['vue', 'javascript'],
\    'zsh': 'sh',
\}
let g:ale_fixers = {
\    '*': ['remove_trailing_lines', 'trim_whitespace'],
\    'c': ['remove_trailing_lines', 'trim_whitespace', 'clang-format', 'astyle', 'uncrustify'],
\    'cpp': ['remove_trailing_lines', 'trim_whitespace', 'clang-format', 'astyle', 'uncrustify'],
\    'go': ['remove_trailing_lines', 'trim_whitespace', 'gofmt', 'goimports', 'gomod'],
\    'html': ['remove_trailing_lines', 'trim_whitespace', 'prettier'],
\    'javascript': ['remove_trailing_lines', 'trim_whitespace', 'eslint', 'prettier'],
\    'json': ['remove_trailing_lines', 'trim_whitespace', 'jq', 'prettier'],
\    'latex': ['remove_trailing_lines', 'trim_whitespace', 'latexindent'],
\    'markdown': ['remove_trailing_lines', 'trim_whitespace', 'prettier'],
\    'nix': ['remove_trailing_lines', 'trim_whitespace', 'nixfmt', 'nixpkgs-fmt'],
\    'python': ['remove_trailing_lines', 'trim_whitespace', 'black'],
\    'rust': ['remove_trailing_lines', 'trim_whitespace', 'rustfmt'],
\    'sh': ['remove_trailing_lines', 'trim_whitespace', 'shfmt'],
\    'terraform': ['remove_trailing_lines', 'trim_whitespace', 'terraform'],
\    'typescript': ['remove_trailing_lines', 'trim_whitespace', 'tslint', 'prettier'],
\    'vue': ['remove_trailing_lines', 'trim_whitespace', 'prettier'],
\}
let g:ale_fix_on_save = 1
let g:ale_history_enabled = 1
let g:ale_hover_to_preview = 1
let g:ale_linters = {
\    '*': ['proselint', 'vale'],
\    'ansible': ['ansible-lint'],
\    'c': ['cc', 'ccls', 'clangtidy', 'flawfinder'],
\    'cpp': ['cc', 'ccls', 'clangtidy', 'flawfinder'],
\    'css': ['csslint'],
\    'elixir': ['dialyxir', 'dogma', 'elixir_ls', 'mix'],
\    'elm': ['elm_ls'],
\    'erlang': ['dialyzer', 'elvis', 'erlc', 'syntaxerl'],
\    'dockerfile': ['hadolint'],
\    'fish': ['fish'],
\    'gitcommit': ['gitlint'],
\    'go': ['bingo', 'golint', 'gotype', 'staticcheck'],
\    'html': ['tidy', 'proselint'],
\    'java': ['javac', 'checkstyle', 'javalsp'],
\    'javascript': ['eslint', 'flow', 'flow-language-server'],
\    'json': ['jq', 'jsonlint'],
\    'make': ['checkmake'],
\    'markdown': ['mdl', 'proselint', 'vale'],
\    'nix': ['nix', 'rnix-lsp'],
\    'powershell': ['powershell'],
\    'python': ['mypy', 'pylint', 'flake8', 'pyre'],
\    'rust': ['rustc', 'cargo', 'rls', 'analyzer'],
\    'sh': ['shell', 'bashate', 'shellcheck'],
\    'sql': ['sqlint'],
\    'systemd': ['systemd-analyze'],
\    'terraform': ['terraform', 'tflint', 'terraform_ls', 'terraform_lsp'],
\    'tex': ['texlab', 'proselint', 'vale'],
\    'vim': ['ale_custom_linting_rules', 'vint'],
\    'yaml': ['yamllint'],
\}
let g:ale_linters_explicit = 1
let g:ale_lsp_suggestions = 1
let g:ale_max_buffer_history_size = 100
let g:ale_maximum_file_size = 52428800 " 50MiB

" Disable ale for minified files
let g:ale_pattern_options = {
\    '\.min.js$': {
\        'ale_enabled': 0
\    },
\    '\.min.css$': {
\        'ale_enabled': 0
\    },
\}
let g:ale_sign_column_always = 1
let g:ale_virtualtext_cursor = 1
let g:ale_sh_shellcheck_options = '-x'
let g:ale_python_black_options = '-l 79'

" Setup VimSence for NeoVim
" let g:vimsence_small_text = 'NeoVim'
" let g:vimsence_small_image = 'neovim'

lua <<EOF
-- Set up nvim web icons
require'nvim-web-devicons'.setup {
  default = true;
}

-- Set up NVim-Treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  ignore_install = {},
  highlight = {
    enable = true,
    disable = {},
  },
}
EOF

" Set default TeX style
" let g:tex_flavor = 'latex'
