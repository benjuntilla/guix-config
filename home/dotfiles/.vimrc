set nocompatible              
call plug#begin('~/.vim/plugged')
Plug 'VundleVim/Vundle.vim'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'preservim/nerdcommenter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'terryma/vim-multiple-cursors'
Plug 'matze/vim-move'
Plug 'preservim/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'ryanoasis/vim-devicons'
Plug 'tpope/vim-surround'
Plug 'lambdalisue/suda.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()
filetype plugin indent on

set number
set mouse=a
syntax on
map <C-b> :NERDTreeToggle<CR>
let g:move_key_modifier = 'C'
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme="distinguished"
let g:airline_powerline_fonts = 1
