"plugins
if empty(glob('~/.vim/autoload/plug.vim'))
	silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
	      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'mindriot101/vim-yapf'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'rust-lang/rust.vim'
"Plug 'racer-rust/vim-racer'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"Plug 'vim-syntastic/syntastic'
Plug 'python-mode/python-mode', { 'branch': 'develop' }
Plug 'peterhoeg/vim-qml'
call plug#end()

let mapleader = "<"

"airline
let g:airline_powerline_fonts = 1
let g:airline_theme='distinguished'

"vim racer Cx Co to autocomplete
set hidden
let g:racer_cmd = "~/.cargo/bin/racer"
let g:racer_experimental_completer = 1
au FileType rust nmap gd <Plug>(rust-def)
au FileType rust nmap gs <Plug>(rust-def-split)
au FileType rust nmap gx <Plug>(rust-def-vertical)
au FileType rust nmap <leader>gd <Plug>(rust-doc)
au FileType rust nmap <leader>f :RustFmt<CR>

"syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

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

"pymode
let g:pymode_python = 'python3'
let g:pymode=1
let g:pymode_options_colorcolumn = 0
"let g:pymode_indent = 1

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
nnoremap <leader>f :call Yapf()<CR>
