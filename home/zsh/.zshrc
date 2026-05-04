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
typeset -A key

PROMPT='%F{cyan}%2~%F{red}$(git branch 2>/dev/null | grep "\*" | awk '\''{print " " $NF }'\'' | sed "s/)//g")%F{3}> %f'

export EDITOR=nvim
export SUDO_EDITOR=$EDITOR
export VISUAL=$EDITOR
export SDL_AUDIODRIVER=pipewire
export REPORTTIME=1
export LESS=Rx4
export PATH=$PATH:~/.local/bin
export TERM=xterm

function ztrim() { sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' $@ }

alias git='noglob git'
alias viless='/usr/share/nvim/runtime/scripts/less.sh'
alias reswap='sudo /bin/swapoff -a && sudo /bin/swapon -a'
alias ls='ls -AF --color=auto'
alias sudo='sudo '
alias sourcesh='source $HOME/.zshrc'
alias vim='nvim'
alias grep="/bin/rg"
alias grem="/bin/rg --color ansi -g '*.{py,m,jl,sh,lua}'"
alias grec="/bin/rg --color ansi -g '*.{c,h,cpp,hpp,rs,zig,nim}'"
function greb() { /bin/rg -aPo --no-mmap --line-buffered --trim --column --color=never ".{0,60}$1.{0,60}" ${@:2} | while read -r line; do; echo $line | strings -w -s " " | ztrim; done }
alias history='history 1'

function updatedb() { /usr/bin/updatedb --require-visibility 0 -o $HOME/.locate.db --prune-bind-mounts no ; }
function pacfiles() { pacman -Qlq $@ | grep -v '/$' | xargs -r du -h | sort -h ; }
function locate() { /usr/bin/locate --database=$HOME/.locate.db $@ ; }

# enable completion
zstyle ':completion:*' completer _expand _complete _ignored _correct _list _oldlist 
zstyle ':completion:*' completions 1 glob 1 insert-unambiguous 1 rehash 1
zstyle ':completion::complete:*' use-cache 1 cache-path $ZCACHE
zstyle :compinstall filename '$HOME/.zshrc'
autoload -Uz compinit promptinit
[[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
compinit -d $ZCACHE/.zcompdump-$ZSH_VERSION
promptinit

if [ -n "$DESKTOP_SESSION" ];then
    export SSH_AUTH_SOCK
fi

###########################################################
#### zle functions and shortcuts (history search, etc) ####
###########################################################

zle_highlight=('paste:none')
autoload -U zargs

function commandline-execute {
    BUFFER="$@"
    zle accept-line
}

function _print-git-repo-name-and-status {
    cd $@
    MOD=$(git status --untracked-files=no --short | cut -c1-3)
    NUM=$(echo $MOD | grep . | wc -l)
    if [ $NUM -eq 0 ]; then
        if [ $(git log --branches --not --remotes | wc -l) -gt 0 ]; then
            ST=" (unpushed)"
            ST="\e[0;33m$ST\e[0m"
        else
            ST=""
        fi
    elif [ $( echo $MOD | cut -c2-2 | grep "M" | wc -l) -gt 0 ]; then
        ST=" (modified:$NUM)"
        ST="\e[0;31m$ST\e[0m"
    elif [ $( echo $MOD | grep "M  " | wc -l) -gt 0 ]; then
        ST=" (staged:$NUM)"
        ST="\e[0;32m$ST\e[0m"
    else
        ST=" (??:$NUM)"
        ST="\e[0;31m$ST\e[0m"
    fi
    print "$@$ST"
}
function locate-git-repos {
    dirname $(locate "/.git" | rg "/.git\$" | rg -v ".*/\..+/.+*")
}
function locate-git-repos-and-status {
    zargs -P 32 -I {} -- $(locate-git-repos) -- _print-git-repo-name-and-status {}
}
function _goto-git-repo {
    local REPORTTIME=-1
    FILE=$(locate-git-repos-and-status | tac | fzf --exact --no-sort --cycle --ansi | awk '{print $1}') && [[ -d $FILE ]] && commandline-execute "cd $FILE"
}
zle -N _goto-git-repo
bindkey "^G" _goto-git-repo # Ctrl-G goto git repo

function _ls-files-git-with-status {
    FILT="(^|/)\.?[^\.^/]+($|\.txt$)"
    GITROOTDIR=$(git rev-parse --show-toplevel 2>/dev/null) && \
    GITFILES=$(git ls-files $GITROOTDIR | /bin/grep -Fxvf  <(git config --file .gitmodules --name-only --get-regexp path | cut -d '.' -f2-2) ) && \
    GITFILES=$({ echo $GITFILES | /bin/rg -e $FILT ; echo $GITFILES | /bin/rg -ve $FILT}) && \
    MODIFIED=$(git status --untracked-files=no | grep "\t" | sed 's/\t//' | grep . | sort | uniq | tac) && \
    UNMODIFIED=$(/bin/grep -Fvxf <(git status --untracked-files=no --porcelain=1 | cut -d " " -f 3) <(echo $GITFILES) | sed 's/^/  /' | tac) && \
    {echo $MODIFIED ; echo $UNMODIFIED} | grep .
}
function _ls-files-git {
    _ls-files-git-with-status | awk -F ':' '{print $NF}' | tr -d ' '
}

function _search-file-git {
    _ls-files-git-with-status | fzf --exact --no-sort --cycle | awk -F ':' '{print $NF}' | tr -d ' '
}
function _search-and-edit-file-git {
    local REPORTTIME=-1
    FILE=$(_search-file-git) && [[ -n $FILE ]] && commandline-execute "$EDITOR $FILE"
}
zle -N _search-and-edit-file-git
bindkey "^F" _search-and-edit-file-git # Ctrl-F git file search

function _search-and-edit-line-git {
    local REPORTTIME=-1
    export TEMP=$(mktemp -u)
    trap 'rm -f "$TEMP"' EXIT
    FILES=$(_ls-files-git | tr '\n' ' ')
    TR_CHANGE='rg_pat={q:1}      # The first word is passed to ripgrep
    fzf_pat={q:2..}   # The rest are passed to fzf
    if ! [[ -r "$TEMP" ]] || [[ $rg_pat != $(cat "$TEMP") ]]; then
        echo "$rg_pat" > "$TEMP"
        printf "+reload:sleep 0.1; rg --column --line-number --no-heading --color=always --smart-case %q '$FILES' || true" "$rg_pat"
    fi
    echo "+search:$fzf_pat"'
    TR_RESIZE='if (( FZF_LINES > 18 && (FZF_COLUMNS < 5*FZF_LINES || FZF_COLUMNS <= 150) )); then; echo "change-preview-window:up,50%,border-bottom"
    elif (( FZF_COLUMNS > 150 )); then; echo "change-preview-window:right,50%,border-left";
    else echo "+change-preview-window:hidden"; fi'
    fzf --ansi --exact --smart-case --cycle \
        --color "hl:-1:underline:bold,hl+:-1:underline:reverse" \
        --with-shell 'zsh -c' \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'hidden,+{2}+3/3,~3' \
        --bind 'start,change:transform:'$TR_CHANGE \
        --bind 'focus,resize:transform:'$TR_RESIZE \
        --bind 'enter:become(vim {1} +{2})' \
        --delimiter :
}
zle -N _search-and-edit-line-git
bindkey "^E" _search-and-edit-line-git # Ctrl-E for search-in-files

function _reverse-history-search {
    local REPORTTIME=-1
    LINE=$(fc -lnr 0 | fzf --exact --no-sort --bind=ctrl-e:accept) && \
        zle kill-whole-line && zle -U $LINE
}
zle -N _reverse-history-search
bindkey "^R" _reverse-history-search # Ctrl-R reverse history search

###################################################################
#### start background jobs on init (update plocate, gitindex) #####
###################################################################

function _zsh-background-init {
    updatedb
    locate-git-repos-and-status
}
function _zsh-background-init-fork {
    _zsh-background-init &
}
if [ -z $ZSH_LAST_BACKGROUND_INIT -o $(( $(date +%s) > $ZSH_LAST_BACKGROUND_INIT+3600 )) -eq 1 ]; then
    export ZSH_LAST_BACKGROUND_INIT=$(date +%s)
    _updatedb_and_gitindex > /dev/null 2>&1
fi
