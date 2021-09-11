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

# Use caching so that commands like pacman complete are useable
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $HOME/.zsh/cache/

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

my-script_widget() tmux next-window
zle -N my-script_widget
bindkey '^[\t' my-script_widget

# set xfce4-terminal to use 8-bit colors
if [[ -e /usr/share/terminfo/x/xterm-256color ]] && [[ "$COLORTERM" == "xfce4-terminal" ]]; then
	export TERM=xterm-256color
fi

######################################################
#######    exports, aliases and functions     ########
######################################################

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
export LESS=Rx4

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
alias keyboard='$HOME/.set_keyboard'

function grer() {
/bin/grep -rna --color=always --include "*.*" --exclude="*.o" --exclude="*.a" --exclude="*.dll" --exclude-dir ".*" --exclude-dir="nimcache" ${@} | /bin/cut -c1-400 | less
}

######################################################
################    zaw     ##########################
######################################################

source /usr/share/zaw/zaw.zsh
bindkey "^X" zaw
bindkey "^R" zaw-history    # Ctrl-R history search
bindkey "^F" zaw-git-files  # Ctrl-F git file search
bindkey -M filterselect "^R" down-line-or-history
bindkey -M filterselect "^S" up-line-or-history
bindkey -M filterselect "^E" accept-search
bindkey -M filterselect "^A" accept-search
zstyle ':filter-select:highlight' matched fg=green
zstyle ':filter-select' max-lines -2
zstyle ':filter-select' rotate-list yes
zstyle ':filter-select' case-insensitive yes
zstyle ':filter-select' hist-find-no-dups yes


######################################################
#################   conda    #########################
######################################################
#
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
	eval "$__conda_setup"
else
	if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
		. "/opt/miniconda3/etc/profile.d/conda.sh"
	else
		export PATH="/opt/miniconda3/bin:$PATH"
	fi
fi
unset __conda_setup

######################################################
################    zgen    ##########################
######################################################

# load zgen
source "${HOME}/.zgen/zgen.zsh"

# if the init scipt doesn't exist
if ! zgen saved; then
	zgen oh-my-zsh
	zgen oh-my-zsh plugins/git
	zgen oh-my-zsh plugins/sudo
	zgen oh-my-zsh plugins/command-not-found
	zgen oh-my-zsh plugins/zsh_reload
	zgen load zsh-users/zsh-syntax-highlighting
	zgen load zsh-users/zsh-autosuggestions
	zgen loadall <<EOPLUGINS # bulk load
EOPLUGINS
	# ^ can't indent this
	zgen load zsh-users/zsh-completions src
	zgen oh-my-zsh themes/robbyrussell
	zgen save # save all to init script
fi
