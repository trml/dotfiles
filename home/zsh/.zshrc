[ -L $HOME/.zshrc ] && DOTFILES=$(cd $HOME/`readlink $HOME/.zshrc | xargs dirname` && git rev-parse --show-toplevel)

if [ ! $DOTFILES = "" ]; then
# antigen
source $DOTFILES/antigen/antigen.zsh
antigen use oh-my-zsh # this command should be applied before loading zaw since it changes some things
antigen bundle colored-man-pages
antigen bundle command-not-found
antigen bundle copybuffer
antigen bundle themes
antigen bundle vundle
antigen bundle zsh_reload
antigen bundle zsh-users/zsh-syntax-highlighting
antigen theme robbyrussell
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

# The following lines were added by compinstall
zstyle :compinstall filename '$HOME/.zshrc'

autoload -U compinit
compinit
# End of lines added by compinstall

autoload -U zmv

# exports, aliases and functions
export SUDO_EDITOR='/bin/vim'
export VISUAL='/bin/vim'
export EDITOR='/bin/vim'
export ZAW_EDITOR='/bin/vim'
export SDL_AUDIODRIVER=alsa
export REPORTTIME=1
export PATH=/usr/lib:$PATH
export PATH=/usr/bin:/bin/:$PATH
export PATH=$HOME/bin:$PATH
export PATH=$HOME/build/nim/bin:$PATH
export PATH=$HOME/.nimble/bin:$PATH
export XDG_DATA_HOME=$HOME

alias valgrind-callgrind='/bin/valgrind --tool=callgrind --dump-line=yes --dump-instr=yes --collect-jumps=yes --collect-systime=yes --cache-sim=yes --branch-sim=yes -v --instr-atstart=no'
alias mmv='noglob zmv -W'
alias reswap='sudo /bin/swapoff -a && sudo /bin/swapon -a'
alias ls='/bin/ls --color=auto'
#alias packer='/bin/packer-color'
alias viless='/usr/share/vim/vim80/macros/less.sh'
alias grep='/bin/grep --color=auto'
alias gret='/bin/git log --all -p | /bin/grep -inI --color=auto --exclude-dir ".*"'
alias sudo='/bin/sudo '
alias updatedb='/usr/bin/updatedb --require-visibility 0 -o $HOME/.locate.db'
alias locate='/usr/bin/locate --database=$HOME/.locate.db'
alias mountrw='mount -o gid=users,fmask=113,dmask=002'
alias sourcezsh='source $HOME/.zshrc'
alias sship='$(echo $SSH_CLIENT | awk '\''{ print $1}'\'')'

function grer() {
/bin/grep -rna --color=always --include "*.*" --exclude="*.o" --exclude="*.a" --exclude="*.dll" --exclude-dir ".*" ${@} | /bin/cut -c1-200
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

# set xfce4-terminal to use 8-bit colors
if [[ -e /usr/share/terminfo/x/xterm-256color ]] && [[ "$COLORTERM" == "xfce4-terminal" ]]; then
	export TERM=xterm-256color
fi
