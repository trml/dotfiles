[ -L $HOME/.zshrc ] && DOTFILES=$(cd $HOME/`readlink $HOME/.zshrc | xargs dirname` && git rev-parse --show-toplevel)

# The following lines were added by compinstall
zstyle :compinstall filename '$HOME/.zshrc'
autoload -U compinit

#fpath=(/usr/local/share/zsh-completions $fpath)
#rm -f "$HOME/.zcompdump"
compinit -u -D

if [ ! $DOTFILES = "" ]; then
# antigen
source $DOTFILES/antigen/antigen.zsh
antigen use oh-my-zsh # this command should be applied before loading zaw since it changes some things
antigen bundle colored-man-pages
antigen bundle command-not-found
antigen bundle copybuffer
antigen bundle zsh_reload
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle wting/autojump
antigen bundle supercrabtree/k
#antigen bundle themes
#antigen theme robbyrussell
antigen theme "$DOTFILES/local" fishy-custom.zsh-theme --no-local-clone
antigen apply

# zaw (ctrl-R history search)
source $DOTFILES/zaw/zaw.zsh
bindkey "^X" zaw
bindkey "^R" zaw-history
bindkey "^F" zaw-git-files
bindkey -M filterselect "^R" down-line-or-history
bindkey -M filterselect "^S" up-line-or-history
bindkey -M filterselect "^E" accept-search
bindkey -M filterselect "^A" accept-search
zstyle ':filter-select:highlight' matched fg=green
zstyle ':filter-select' max-lines -2
zstyle ':filter-select' rotate-list yes
zstyle ':filter-select' case-insensitive yes
zstyle ':filter-select' hist-find-no-dups yes

fi # finished adding things from dotfiles repo

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=$HISTSIZE
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt appendhistory
setopt autocd
setopt extendedglob
setopt nomatch
setopt completealiases
unsetopt beep notify
bindkey -e

autoload -U zmv

# exports, aliases and functions
export SUDO_EDITOR='/usr/bin/nvim'
export VISUAL='/usr/bin/nvim'
export EDITOR='/usr/bin/nvim'
export ZAW_EDITOR='/usr/bin/nvim'
export SDL_AUDIODRIVER=alsa
export REPORTTIME=1
export PATH=/usr/lib:$PATH
export PATH=/usr/bin:/bin/:$PATH
export PATH=$HOME/bin:$PATH
export PATH=$HOME/build/nim-lang-nim/bin:$PATH
export PATH=$HOME/.nimble/bin:$PATH
export PATH=$DOTFILES/bin:$PATH
export PATH=$HOME/.dotnet:$PATH
export PATH=$HOME/.dotnet/tools:$PATH
export XDG_DATA_HOME=$HOME

alias valgrind-callgrind='/bin/valgrind --tool=callgrind --dump-line=yes --dump-instr=yes --collect-jumps=yes --collect-systime=yes --cache-sim=yes --branch-sim=yes -v --instr-atstart=no'
alias mmv='noglob zmv -W'
alias reswap='sudo /bin/swapoff -a && sudo /bin/swapon -a'
alias ls='/bin/ls --color=auto'
#alias packer='/bin/packer-color'
alias viless='/usr/share/vim/vim81/macros/less.sh'
alias grep='/bin/grep --color=auto'
alias gret='/bin/git log --all -p | /bin/grep -inI --color=auto --exclude-dir ".*"'
alias sudo='/bin/sudo '
alias updatedb='/usr/bin/updatedb --require-visibility 0 -o $HOME/.locate.db'
alias locate='/usr/bin/locate --database=$HOME/.locate.db'
alias mountrw='mount -o gid=users,fmask=113,dmask=002'
alias sourcezsh='source $HOME/.zshrc'
alias sship='$(echo $SSH_CLIENT | awk '\''{ print $1}'\'')'
alias connectedscreen='$(xrandr -q | grep " connected" | awk "{print $1}" | head -1)'
alias i3lock='i3lock --color=000000'
alias bam5='$HOME/build/matricks-bam/bam'
alias vim='nvim'

function grer() {
/bin/grep -rna --color=always --include "*.*" --exclude="*.o" --exclude="*.a" --exclude="*.dll" --exclude-dir ".*" --exclude-dir="nimcache" ${@} | /bin/cut -c1-400 | less
}

function greb() {
	echo "$(/bin/grep -nira --color=none --include "*.*" --exclude="*.o" --exclude="*.a" --exclude="*.dll" --exclude-dir ".*" --exclude-dir="nimcache" ${@} | cut -d: -f1-2 | sed 's/:/ /g' | awk '{ print "git blame "$1" -L "$2","$2}')" | bash | cat
}

function mtex() {
	pdflatex main && pdflatex main && bibtex main && pdflatex main && pdflatex main
}

function maketex() {
	pdflatex "$@" && pdflatex "$@" && bibtex "$@" && pdflatex "$@" && pdflatex "$@"
}

function dotfiles() {
	(cd $DOTFILES && command make "$@")
}

# Use caching so that commands like pacman complete are useable
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $HOME/.zsh/cache/

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup key accordingly
[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
[[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char
[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       up-line-or-search
[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     down-line-or-search
[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   beginning-of-buffer-or-history
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history

my-script_widget() tmux next-window
zle -N my-script_widget
bindkey '^[\t' my-script_widget
#bindkey '^[\t' 
#bindkey 'Alt+
#bindkey '^[[Z' reverse-menu-complete
#
#'^[\t''^[\t'


# set xfce4-terminal to use 8-bit colors
if [[ -e /usr/share/terminfo/x/xterm-256color ]] && [[ "$COLORTERM" == "xfce4-terminal" ]]; then
	export TERM=xterm-256color
fi

setxkbmap -layout no -option caps:escape -option nbsp:none
xmodmap -e 'keycode 0x3b = comma semicolon comma semicolon less dead_ogonek dead_cedilla' # bind altgr+comma/period to < and >
xmodmap -e 'keycode 0x3c = period colon period colon greater periodcentered ellipsis'
