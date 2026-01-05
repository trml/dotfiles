" From defaults.vim
if v:progname =~? "evim"
	finish
endif
if exists('skip_defaults_vim')
	finish
endif
if &compatible
	set nocompatible
endif

set ttimeout
set ttimeoutlen=100
set display=truncate
set scrolloff=5
set nrformats-=octal
if has('win32')
	set guioptions-=t
endif
map Q gq
sunmap Q
inoremap <C-U> <C-G>u<C-U>

set backspace=indent,eol,start
set ruler
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.png,.jpg " lower priority suffixes for completions
set suffixes-=.h
set suffixes-=.obj

set showmatch
set ignorecase
set mouse=a
set mousemodel=popup_setpos
set hlsearch
set incsearch
set wildmode=longest,list
set showcmd " display incomplete commands
" set formatoptions-=t
setlocal formatoptions-=t
setlocal formatoptions-=c
if has('nvim')
	lua vim.api.nvim_create_autocmd("FileType", { callback = function() vim.opt_local.formatoptions:remove("c") end, })
endif

set viewoptions=cursor,folds,slash,unix
set grepprg=grep\ -nH\ $*
set history=5000 " keep 200 lines of command line history

let mapleader = "."

set viminfo='20,<1000,s1000

set clipboard=unnamedplus
" use */+ to yank to primary/system clipboard
vnoremap <LeftRelease> "+y<LeftRelease>

set exrc
set secure
nnoremap <esc> :noh<cr>

" Match brackets and use sharper colors than default
source $VIMRUNTIME/pack/dist/opt/matchit/plugin/matchit.vim

" Return to previous cursor position when opening a file
autocmd BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$") && &filetype !~# 'commit' && index(['xxd', 'gitrebase'], &filetype) == -1 && !&diff | exe "normal! g`\"" | endif

" Rules for tabs/indents
set list listchars=tab:>·,extends:>,precedes:<,trail:¬,nbsp:█
set cino=:0,l1,g0,(0,u0,W2s
set sw=2 ts=2 sts=2 noexpandtab
autocmd Filetype c,cpp,h,hpp,java setlocal ts=4 sw=4 sts=0 noexpandtab
autocmd Filetype rust,rs,python,musicxml,xml,nim,nimrod,julia,matlab,octave setlocal ts=2 sw=2 sts=0 noexpandtab

" Define binds for commenting / uncommenting blocks of code
let b:ccl = '#'
autocmd FileType c,cpp,h,hpp,java,scala,php,javascript,js,ts,jsx,tsx let b:ccl = '//'
autocmd FileType matlab,tex,bib let b:ccl = '%'
autocmd FileType vim let b:ccl = '"'
autocmd FileType markdown let b:ccl = '<---'
function! Comment()
	exe "s@^@".b:ccl." @"
endfun
function! UnComment()
	exe "s@^[\ ]*".b:ccl." @@e"
endfun
function! ToggleComment()
	exe "s@^@".b:ccl." @ | s@^".b:ccl." ".b:ccl." @@e"
endfun
noremap <leader>cc :call Comment()<CR>
noremap <leader>cu :call UnComment()<CR>
noremap <leader>ci :call ToggleComment()<CR>

filetype plugin indent on
syntax enable
syntax on

set cmdheight=1
set laststatus=2
set statusline=%<%f\ %h%m%r\ %y%=%{v:register}\ %-14.(%l,%c%V%)\ %P

set backupdir=$HOME/.vim/tmp
set directory=$HOME/.vim/tmp
set undodir=$HOME/.vim/tmp
call mkdir(expand("$HOME/.vim/tmp"), "p")
set undofile
set undoreload=10000

" Make shift-insert work like in Xterm
if has('gui_running')
	map <S-Insert> <MiddleMouse>
	map! <S-Insert> <MiddleMouse>
endif

set termguicolors
colorscheme ron

if &term == 'xterm-ghostty'
	" inherit colorscheme from ghostty
	set background=dark
	hi clear
	set notermguicolors
	colorscheme default

	hi NonText ctermfg=0
	hi Ignore ctermfg=NONE  ctermbg=NONE cterm=NONE
	hi Underlined cterm=underline
	hi Bold cterm=bold
	hi Italic cterm=italic
	hi StatusLine ctermfg=15 ctermbg=8 cterm=NONE
	hi StatusLineNC ctermfg=15 ctermbg=0 cterm=NONE
	hi VertSplit ctermfg=8
	hi TabLine ctermfg=7 ctermbg=0
	hi TabLineFill ctermfg=0 ctermbg=NONE
	hi TabLineSel ctermfg=0 ctermbg=11
	hi Title ctermfg=4 cterm=bold
	hi CursorLine ctermbg=0 ctermfg=NONE
	hi Cursor ctermbg=15 ctermfg=0
	hi CursorColumn ctermbg=0
	hi LineNr ctermfg=8
	hi CursorLineNr ctermfg=6
	hi helpLeadBlank ctermbg=NONE ctermfg=NONE
	hi helpNormal ctermbg=NONE ctermfg=NONE
	hi Visual ctermbg=8 ctermfg=15 cterm=bold
	hi VisualNOS ctermbg=8 ctermfg=15 cterm=bold
	hi Pmenu ctermbg=0 ctermfg=15
	hi PmenuSbar ctermbg=8 ctermfg=7
	hi PmenuSel ctermbg=8 ctermfg=15 cterm=bold
	hi PmenuThumb ctermbg=7 ctermfg=NONE
	hi FoldColumn ctermfg=7
	hi Folded ctermfg=12
	hi WildMenu ctermbg=0 ctermfg=15 cterm=NONE
	hi SpecialKey ctermfg=0
	hi IncSearch ctermbg=1 ctermfg=0
	hi CurSearch ctermbg=3 ctermfg=0
	hi Search ctermbg=11 ctermfg=0
	hi Directory ctermfg=4
	hi MatchParen ctermbg=0 ctermfg=3 cterm=underline
	hi SpellBad cterm=undercurl
	hi SpellCap cterm=undercurl
	hi SpellLocal cterm=undercurl
	hi SpellRare cterm=undercurl
	hi ColorColumn ctermbg=8
	hi SignColumn ctermfg=7
	hi ModeMsg ctermbg=15 ctermfg=0 cterm=bold
	hi MoreMsg ctermfg=4
	hi Question ctermfg=4
	hi QuickFixLine ctermbg=0 ctermfg=14
	hi Conceal ctermfg=8
	hi ToolbarLine ctermbg=0 ctermfg=15
	hi ToolbarButton ctermbg=8 ctermfg=15
	hi debugPC ctermfg=7
	hi debugBreakpoint ctermfg=8
	hi ErrorMsg ctermfg=1 cterm=bold,italic
	hi WarningMsg ctermfg=11
	hi DiffAdd ctermbg=10 ctermfg=0
	hi DiffChange ctermbg=12 ctermfg=0
	hi DiffDelete ctermbg=9 ctermfg=0
	hi DiffText ctermbg=14 ctermfg=0
	hi diffAdded ctermfg=10
	hi diffRemoved ctermfg=9
	hi diffChanged ctermfg=12
	hi diffOldFile ctermfg=11
	hi diffNewFile ctermfg=13
	hi diffFile ctermfg=12
	hi diffLine ctermfg=7
	hi diffIndexLine ctermfg=14
	hi healthError ctermfg=1
	hi healthSuccess ctermfg=2
	hi healthWarning ctermfg=3

	" Syntax
	hi Comment ctermfg=8 cterm=italic
	hi Constant ctermfg=3
	hi Error ctermfg=1
	hi Identifier ctermfg=9
	hi Function ctermfg=4
	hi Special ctermfg=13
	hi Statement ctermfg=5
	hi String ctermfg=2
	hi Operator ctermfg=6
	hi Boolean ctermfg=3
	hi Label ctermfg=14
	hi Keyword ctermfg=5
	hi Exception ctermfg=5
	hi Conditional ctermfg=5
	hi PreProc ctermfg=13
	hi Include ctermfg=5
	hi Macro ctermfg=5
	hi StorageClass ctermfg=11
	hi Structure ctermfg=11
	hi Todo ctermfg=0 ctermbg=9 cterm=bold
	hi Type ctermfg=11

	if has('nvim')
		hi NormalFloat ctermbg=0 ctermfg=15
		hi FloatBorder ctermbg=0 ctermfg=7
		hi FloatShadow ctermbg=0 ctermfg=15
	endif

	" override cursor colors
	set cursorline
	set cursorlineopt=line
	hi Cursor ctermbg=15 ctermfg=8
	hi CursorLine term=NONE ctermfg=15 ctermbg=8 "8 = dark gray, 15 = white
	hi MatchParen ctermbg=blue guibg=lightblue
endif
