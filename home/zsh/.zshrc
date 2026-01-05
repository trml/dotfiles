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
setopt interactivecomments
unsetopt beep notify
bindkey -e

export EDITOR='/bin/vim'
export SUDO_EDITOR='/bin/vim'
export VISUAL='/bin/vim'
export ZAW_EDITOR='/bin/vim'
export SDL_AUDIODRIVER=pipewire
export REPORTTIME=1
export XDG_DATA_HOME=$HOME
export LESS=Rx4
export PLOTLY_RENDERER="firefox"

export QT_QPA_PLATFORM=xcb
export PATH="$HOME/dotfiles/bin:$PATH"
export PATH="/opt/rocm/bin:$PATH"
export PYTHONPATH="/home/s/build/PLSSVM/build/bindings/Python:$PYTHONPATH"
export QT_FONT_DPI=120
export QT_AUTO_SCREEN_SCALE_FACTOR=1 # make qt use .Xresources dpi setting
export XDG_SESSION_TYPE=wayland

alias valgrind-callgrind='/bin/valgrind --tool=callgrind --dump-line=yes --dump-instr=yes --collect-jumps=yes --collect-systime=yes --cache-sim=yes --branch-sim=yes -v --instr-atstart=no'
alias mmv='noglob zmv -W'
alias reswap='sudo /bin/swapoff -a && sudo /bin/swapon -a'
alias ls='/bin/ls --color=auto'
alias viless='/usr/share/nvim/runtime/macros/less.sh'
alias sudo='/bin/sudo '
alias updatedb='/usr/bin/updatedb --require-visibility 0 -o $HOME/.locate.db'
alias locate='/usr/bin/locate --database=$HOME/.locate.db'
alias mountrw='mount -o gid=users,fmask=113,dmask=002'
alias sourcesh='source $HOME/.zshrc'
alias sship='$(echo $SSH_CLIENT | awk '\''{ print $1}'\'')'
alias connectedscreen='$(xrandr -q | grep " connected" | awk "{print $1}" | head -1)'
alias i3lock='i3lock --color=000000'
alias bam5='$HOME/build/matricks-bam/bam'
# alias vim='nvim'
alias asan_log='UBSAN_OPTIONS=log_path=./SAN:print_stacktrace=1:halt_on_errors=0 ASAN_OPTIONS=log_path=./SAN:print_stacktrace=1:check_initialization_order=1:detect_leaks=1:halt_on_errors=0'
alias grep="/bin/rg"
alias grem="/bin/rg -g '*.{py,m}'"
alias grec="/bin/rg -g '*.{c,h,cpp,hpp}'"
alias ddnet='$HOME/build/trml-ddnet/Release/DDNet'
alias history='history 1'

function pacfiles() {
  pacman -Qlq $@ | grep -v '/$' | xargs -r du -h | sort -h
}
function cpr() {
  rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 "$@"
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

# set terminal to use 8-bit colors
# if [[ -e /usr/share/terminfo/x/xterm-256color ]] && [[ "$COLORTERM" == "truecolor" ]]; then
  #export TERM=xterm-256color
# fi

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
###############    conda / mamba    #######################
###########################################################
# Installation:
#  "${SHELL}" <(curl -L micro.mamba.pm/install.sh)

export MAMBA_EXE='/usr/bin/micromamba';
if [ -f $MAMBA_EXE ]; then
  alias conda='micromamba'
  export MAMBA_ROOT_PREFIX='$HOME/micromamba';
  __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
  else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
  fi
  unset __mamba_setup
  if [ -z $CONDA_DEFAULT_ENV ]; then
    conda activate numpy
  else
    conda activate $CONDA_DEFAULT_ENV
  fi
fi

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/.local/lib/mojo
export PATH=$PATH:~/.modular/pkg/packages.modular.com_mojo/bin/
