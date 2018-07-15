set autoread
syntax on

colorscheme desert

set tabstop=4
set shiftwidth=4
set bg=dark
:set number relativenumber

if empty(glob('~/.vim/autoload/plug.vim'))
	silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
	      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


call plug#begin('~/.vim/plugged')
Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'davidhalter/jedi-vim'
Plug 'chriskempson/base16-vim'
call plug#end()

let g:airline_powerline_fonts = 1
let g:airline_theme='distinguished'

"#vim racer
set hidden
let g:racer_cmd = "~/.cargo/bin/racer"
let g:racer_experimental_completer = 1
au FileType rust nmap gd <Plug>(rust-def)
au FileType rust nmap gs <Plug>(rust-def-split)
au FileType rust nmap gx <Plug>(rust-def-vertical)
au FileType rust nmap <leader>gd <Plug>(rust-doc)
nnoremap <F3> :set hlsearch!<CR>
set nohlsearch
