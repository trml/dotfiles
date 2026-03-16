ZSH=$HOME/.zsh
ZCACHE=$ZSH/cache
[[ ! -d $ZSH ]] && mkdir $ZSH
[[ ! -d $ZCACHE ]] && mkdir -p $ZCACHE

HISTFILE=$ZSH/.histfile
HISTSIZE=20000
SAVEHIST=$HISTSIZE

setopt hist_ignore_all_dups hist_ignore_space appendhistory share_history
setopt extendedglob nomatch completealiases interactivecomments always_to_end
setopt autocd
setopt prompt_subst
unsetopt beep notify list_beep flow_control menu_complete
bindkey -e

PROMPT='%F{cyan}%2~%F{red}$(git branch 2>/dev/null | grep "\*" | awk '\''{print " " $NF }'\'' | sed "s/)//g")%F{3}> %f'

typeset -A key

export EDITOR=nvim
export SUDO_EDITOR=$EDITOR
export VISUAL=$EDITOR
export SDL_AUDIODRIVER=pipewire
export REPORTTIME=1
export LESS=Rx4
export PATH=$PATH:~/.local/bin
[[ -d /opt/rocm/bin ]] && export PATH=$PATH:/opt/rocm/bin

alias git='noglob git'
alias viless='/usr/share/nvim/runtime/scripts/less.sh'
alias reswap='sudo /bin/swapoff -a && sudo /bin/swapon -a'
alias ls='ls -AF --color=auto'
alias sudo='sudo '
alias sourcesh='source $HOME/.zshrc'
alias vim='nvim'
alias grep="/bin/rg"
alias grem="/bin/rg -g '*.{py,m}'"
alias grec="/bin/rg -g '*.{c,h,cpp,hpp}'"
alias history='history 1'

function updatedb() { /usr/bin/updatedb --require-visibility 0 -o $HOME/.locate.db --prune-bind-mounts no ; }
function pacfiles() { pacman -Qlq $@ | grep -v '/$' | xargs -r du -h | sort -h ; }
function locate() { /usr/bin/locate --database=$HOME/.locate.db $@ ; }
# function cpr() {
#   rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 "$@"
# }

# enable completion
zstyle ':completion:*' completer _expand _complete _ignored _correct _list _oldlist 
zstyle ':completion:*' completions 1 glob 1 insert-unambiguous 1 rehash 1
zstyle ':completion::complete:*' use-cache 1 cache-path $ZCACHE
zstyle :compinstall filename '$HOME/.zshrc'
autoload -Uz compinit promptinit
[[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
compinit -d $ZCACHE/.zcompdump-$ZSH_VERSION
promptinit

# set terminal to use 8-bit colors
# if [[ -e /usr/share/terminfo/x/xterm-256color ]] && [[ "$COLORTERM" == "truecolor" ]]; then
  #export TERM=xterm-256color
# fi
if [ -n "$DESKTOP_SESSION" ];then
  #eval $(gnome-keyring-daemon --start)
  export SSH_AUTH_SOCK
fi

###########################################################
#### zle functions and shortcuts (history search, etc) ####
###########################################################

zle_highlight=('paste:none')

function commandline-execute {
	BUFFER="$@"
	zle accept-line
}
function locate-git-repos {
	dirname $(locate "/.git" | rg "/.git\$" | rg -v ".*/\..+/.+*")
}
function _goto-git-repo {
	FILE=$(locate-git-repos | fzf --exact --no-sort) && [[ -d $FILE ]] && commandline-execute "cd $FILE"
}
zle -N _goto-git-repo
bindkey "^G" _goto-git-repo # Ctrl-G goto git repo

function _search-file-git {
	GITROOTDIR=$(git rev-parse --show-toplevel 2>/dev/null) && \
	MODIFIED=$(git status --short --untracked-files=no) && \
	UNMODIFIED=$(comm -13 --nocheck-order <(git status --short | cut -d " " -f 3) <(git ls-files $GITROOTDIR) | sed 's/^/   /') && \
	{echo $MODIFIED ; echo $UNMODIFIED} | fzf --exact --no-sort | cut --complement -c 1-3
}
function _search-and-edit-file-git {
	FILE=$(_search-file-git) && [[ -n $FILE ]] && commandline-execute "$EDITOR $FILE"
}
zle -N _search-and-edit-file-git
bindkey "^F" _search-and-edit-file-git # Ctrl-F git file search

function _reverse-history-search {
	LINE=$(fc -lnr 0 | fzf --exact --no-sort --bind=ctrl-e:accept) && \
	zle kill-whole-line && zle -U $LINE
}
zle -N _reverse-history-search
bindkey "^R" _reverse-history-search # Ctrl-R reverse history search

###########################################################
###############    conda / mamba    #######################
###########################################################
# >>> mamba initialize >>>
# !! Contents within this block are managed by 'micromamba shell init' !!
export MAMBA_EXE='/home/s/.local/bin/micromamba';
export MAMBA_ROOT_PREFIX='y';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from micromamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<
