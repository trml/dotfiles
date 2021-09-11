" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs --insecure
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')
Plug 'vim-scripts/restore_view.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'JuliaLang/julia-vim'
Plug 'tpope/vim-fugitive'
"Plug 'altercation/vim-colors-solarized'
Plug 'zah/nim.vim'
Plug 'iCyMind/NeoSolarized'
Plug 'wlangstroth/vim-racket'
Plug 'jpalardy/vim-slime'
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
call plug#end()

set viewoptions=cursor,folds,slash,unix

set grepprg=grep\ -nH\ $*

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" Suffixes that get lower priority when doing tab completion for filenames.
" These are files we are not likely to want to edit or read.
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.png,.jpg

set history=5000 " keep 200 lines of command line history
set ruler " show the cursor position all the time
set showcmd " display incomplete commands
set incsearch " do incremental searching

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
 \ | wincmd p | diffthis
endif

source /usr/share/nvim/runtime/macros/matchit.vim
set shiftwidth=2
set tabstop=2
set noexpandtab
set cmdheight=1
set softtabstop=2
set listchars=nbsp:█

autocmd Filetype c,cpp,h setlocal ts=4 sw=4 sts=0 noexpandtab cinoptions+=g0
autocmd Filetype c,cpp,h setlocal ts=4 sw=4 sts=0 noexpandtab cinoptions+=g0 list! listchars=tab:>·,extends:>,precedes:<,trail:¬,nbsp:█
"autocmd Filetype python setlocal ts=2 sw=2 sts=0 noexpandtab list! listchars=tab:»·,extends:>,precedes:<,trail:¬,nbsp:█
autocmd Filetype python,musicxml,xml,nim,nimrod,julia,matlab,octave setlocal ts=2 sw=2 sts=2 expandtab list! listchars=tab:»·,extends:>,precedes:<,trail:¬,nbsp:█

syntax enable
syntax on

set clipboard^=unnamedplus
set pastetoggle=<F10>
set viminfo='20,<1000,s1000
nmap <F8> :tabp<cr>
nmap <F9> :tabn<cr>

if has('gui_running')
  " Make shift-insert work like in Xterm
  map <S-Insert> <MiddleMouse>
  map! <S-Insert> <MiddleMouse>
endif

" Lightline
set laststatus=2 " Always display the statusline in all windows
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
let g:lightline = {
      \ 'component': {
      \   'readonly': '%{&readonly?"":""}',
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }
let mapleader = "."

colorscheme ron
"set background=dark

set backupdir=~/.vim/tmp
set directory=~/.vim/tmp

"autocmd filetype c nnoremap <F4> :w <bar> exec '!gcc '.shellescape('%').' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>
autocmd filetype tex nnoremap <F5> :w <bar> exec '!bibtex '.shellescape('%:r').' && !pdflatex '.shellescape('%:r')<CR>

set exrc
set secure
