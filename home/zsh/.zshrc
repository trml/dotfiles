HISTFILE=$HOME/.histfile
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

export SUDO_EDITOR='/bin/nvim'
export VISUAL='/bin/nvim'
export EDITOR='/bin/nvim'
export ZAW_EDITOR='/bin/nvim'
export SDL_AUDIODRIVER=pipewire
export REPORTTIME=1
export XDG_DATA_HOME=$HOME
export LESS=Rx4
export PLOTLY_RENDERER="firefox"

export PATH="$HOME/dotfiles/bin:$PATH"
export QT_AUTO_SCREEN_SCALE_FACTOR=1 # make qt use .Xresources dpi setting

alias valgrind-callgrind='/bin/valgrind --tool=callgrind --dump-line=yes --dump-instr=yes --collect-jumps=yes --collect-systime=yes --cache-sim=yes --branch-sim=yes -v --instr-atstart=no'
alias mmv='noglob zmv -W'
alias reswap='sudo /bin/swapoff -a && sudo /bin/swapon -a'
alias ls='/bin/ls --color=auto'
alias viless='/usr/share/nvim/runtime/macros/less.sh'
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
alias asan_log='UBSAN_OPTIONS=log_path=./SAN:print_stacktrace=1:halt_on_errors=0 ASAN_OPTIONS=log_path=./SAN:print_stacktrace=1:check_initialization_order=1:detect_leaks=1:halt_on_errors=0'
alias grep='/bin/grep --color=auto'
alias ddnet='$HOME/build/trml-ddnet/Release/DDNet'

function gret() {
	/bin/git log --all -p | /bin/grep -inI --color=auto --exclude-dir ".*"
}

function grer() {
	/bin/grep -rna --color=always --include "*.*" --exclude="*.o" --exclude="*.a" --exclude="*.dll" --exclude="*.pyc" --exclude-dir ".*[\.]" --exclude-dir="nimcache" ${@} | /bin/cut -c1-400 | less
}

# enable completion
zstyle ':completion:*' completer _expand _complete _ignored _correct rehash true
zstyle :compinstall filename '/home/s/.zshrc'
autoload -Uz compinit promptinit
compinit
promptinit

# Use caching so that commands like pacman complete are useable
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $HOME/.zsh/cache/
zstyle ':completion:*:*:git:*' script $HOME/.git-completion.bash
fpath=($HOME/.zsh $fpath)

my-script_widget() tmux next-window
zle -N my-script_widget
bindkey '^[\t' my-script_widget

# set xfce4-terminal to use 8-bit colors
if [[ -e /usr/share/terminfo/x/xterm-256color ]] && [[ "$COLORTERM" == "truecolor" ]]; then
	export TERM=xterm-256color
fi

if [ -n "$DESKTOP_SESSION" ];then
    #eval $(gnome-keyring-daemon --start)
    export SSH_AUTH_SOCK
fi

###############################################################
####################    keyboard    ###########################
###############################################################

typeset -A key

##############################################################
##########       plugins, themes/prompt        ###############
##############################################################

export ZPLUGINDIR=$HOME/dotfiles/zsh-plugins

PROMPT='%F{cyan}%2~%F{red}$(git branch 2>/dev/null | grep "\*" | awk '\''{print " " $NF }'\'' | sed "s/)//g")%F{3}> %f'
setopt prompt_subst

source $ZPLUGINDIR/zsh-completions/zsh-completions.plugin.zsh
source $ZPLUGINDIR/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZPLUGINDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# zaw (Ctrl-R history search, etc)
source $ZPLUGINDIR/zaw/zaw.zsh

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

###########################################################
####################   conda    ###########################
###########################################################

export PATH="/opt/miniconda3/bin:$PATH"

__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
		eval "$__conda_setup"
else
		if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
				. "/opt/miniconda3/etc/profile.d/conda.sh"
		fi
fi
unset __conda_setup
