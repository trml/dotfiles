set ttimeout
set ttimeoutlen=100
set display=truncate
set scrolloff=5
set nrformats-=octal
if has('win32')
	set guioptions-=t
endif

set mouse=
set selectmode=
set mousemodel=extend
set backspace=indent,eol,start
set ruler
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.png,.jpg " lower priority suffixes for completions
set suffixes-=.h,.obj

set showmatch ignorecase hlsearch incsearch showcmd nofoldenable
set wildmode=longest,list
setlocal formatoptions-=t,c
if has('nvim')
	lua vim.api.nvim_create_autocmd("FileType", { callback = function() vim.opt_local.formatoptions:remove("c") end, })
endif

set viewoptions=cursor,folds,slash,unix
set grepprg=grep\ -nH\ $*
set history=5000

let mapleader = "."
set viminfo='20,<1000,s1000
set clipboard=unnamedplus
set exrc
set secure

set cmdheight=1
set laststatus=2
set statusline=%<%f\ %h%m%r\ %y%=%{v:register}\ %-14.(%l,%c%V%)\ %P

call mkdir(expand("$HOME/.vim/tmp"), "p")
set backupdir=$HOME/.vim/tmp
set directory=$HOME/.vim/tmp
set undodir=$HOME/.vim/tmp
set undofile
set undoreload=10000

inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>
nnoremap <esc> :noh<cr>
inoremap <s-tab> <c-d>
nnoremap > >>
nnoremap < <<
vnoremap < <gv
vnoremap > >gv
vnoremap = =gv

autocmd BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$") && &filetype !~# 'commit' && index(['xxd', 'gitrebase'], &filetype) == -1 && !&diff | exe "normal! g`\"" | endif

let b:ccl = '#'
autocmd FileType python,julia,nim let b:ccl = '#'
autocmd FileType c,cpp,h,hpp,java,scala,php,javascript,js,ts,jsx,tsx,kotlin,zig,rust let b:ccl = '//'
autocmd FileType matlab,tex,bib,octave let b:ccl = '% '
autocmd FileType vim let b:ccl = '"'
autocmd FileType markdown let b:ccl = '<---'
autocmd FileType lua let b:ccl = '--'
autocmd FileType lisp,gitconfig let b:ccl = ';'
function! Comment()
	exe "s@^\\s*\\zs@".b:ccl."@"
endfun
function! UnComment()
	exe "s@^\\s*\\zs".b:ccl."@@e"
endfun
function! ToggleComment()
	exe "s@^\\s*\\zs@".b:ccl."@ | s@^\\s*\\zs".b:ccl.b:ccl."@@e"
endfun
noremap <leader>cc :call Comment()<CR>
noremap <leader>cu :call UnComment()<CR>
noremap <leader>ci :call ToggleComment()<CR>
vnoremap <leader>cc :call Comment()<CR>gv
vnoremap <leader>cu :call UnComment()<CR>gv
vnoremap <leader>ci :call ToggleComment()<CR>gv

set list listchars=tab:>·,extends:>,precedes:<,trail:¬,nbsp:█
set cino=:0,l1,g0,(0,u0,W2s
set sw=2 ts=2 sts=2 noexpandtab
autocmd Filetype c,cpp,h,hpp,java setlocal ts=4 sw=4 sts=0 expandtab
autocmd Filetype rust,rs,python,musicxml,xml,nim,nimrod,julia,matlab,octave,lua setlocal ts=4 sw=4 sts=0 expandtab

filetype plugin indent on
syntax enable
syntax on

if has('gui_running')
	map <S-Insert> <MiddleMouse>
	map! <S-Insert> <MiddleMouse>
endif

if has('termguicolors') && $COLORTERM=='truecolor'
	set termguicolors
else
	set notermguicolors
endif
colorscheme sorbet
set background=dark

set cursorline
set cursorlineopt=line
