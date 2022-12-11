"plugins
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'arcticicestudio/nord-vim'
Plug 'mindriot101/vim-yapf'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'python-mode/python-mode', { 'branch': 'develop' }
Plug 'peterhoeg/vim-qml'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'vim-autoformat/vim-autoformat'
call plug#end()

" 24 bits colors in tmux
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"


let mapleader = "<"

"airline
let g:airline_powerline_fonts = 1
let g:airline_theme='distinguished'

"autoformat
au BufWrite * :Autoformat

"Zoom
" Zoom / Restore window.
function! s:ZoomToggle() abort
    if exists('t:zoomed') && t:zoomed
        execute t:zoom_winrestcmd
        let t:zoomed = 0
    else
        let t:zoom_winrestcmd = winrestcmd()
        resize
        vertical resize
        let t:zoomed = 1
    endif
endfunction
command! ZoomToggle call s:ZoomToggle()
nnoremap <silent> <leader>z :ZoomToggle<CR>

colorscheme nord
syntax on

"pymode
let g:pymode_python = 'python3'
let g:pymode=1
let g:pymode_options_colorcolumn = 0
"let g:pymode_indent = 1

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)



"general
syntax on
filetype indent on
set nocompatible
set smartindent
set smarttab
set autoindent
set wrap
set showmatch
set ignorecase
set encoding=utf8
set nobackup
set nowb
set noswapfile
set pastetoggle=<F2>
set autoread
set tabstop=4
set shiftwidth=4
set expandtab
set bg=dark
set number relativenumber
set noincsearch
set smarttab
" Displays '-' for trailing space, '>-' for tabs and '_' for non breakable
" space
"set listchars=tab:>-,trail:-,nbsp:_
"set list
"set cursorline
"hi CursorLine cterm=bold ctermbg=233

nnoremap <F3> :set hlsearch!<CR>
nnoremap <F4> :set relativenumber! number!<CR>
"nnoremap <leader>f :call Yapf()<CR>
nnoremap <leader>f :GFiles<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>d :GFiles?<CR>
