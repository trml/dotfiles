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

str_abbrev() {
    abbr="${1[1,$2]}.."              # abbreviate $1 to to $2 characters,
    [ $#abbr -ge $#1 ] && print "$1" || print "$abbr" # return abbreviated if shorter than original
}

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    USERSTR=$(str_abbrev $USER 9)
    HOSTSTR=$(str_abbrev $HOST 9)
    PROMPT="%F{red}$USERSTR@$HOSTSTR $PROMPT"
fi

#if [ -n "$DESKTOP_SESSION" ];then
#export $SSH_AUTH_SOCK
#fi

if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME" ]]; then
    dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:escape']"
    dconf write /org/gnome/desktop/interface/enable-animations "false"
    dconf write /org/gnome/desktop/search-provider/disable-external "true"
    dconf write /org/gnome/SessionManager/logout-prompt "false"
fi

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
function locate() { /usr/bin/locate --existing --database=$HOME/.locate.db $@ ; }

[[ -f /etc/zsh_command_not_found ]] && source /etc/zsh_command_not_found

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

autoload -U zargs
zle_highlight=('paste:none')

function commandline-execute {
    BUFFER="$@"
    zle accept-line
}

######### Search for and goto git repository #############
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
    print "$@\t${@/$HOME/\~}$ST"
}
function locate-git-repos {
    locate --existing "/.git" | rg "/.git\$" | rg -v ".*/\..+/.+*" | while IFS= read -r p; do
        [ -d "$p" ] && print $(dirname $p)
    done
}
function locate-git-repos-and-status {
    zargs -P 32 -I {} $(locate-git-repos) -- _print-git-repo-name-and-status {}
}
function _goto-git-repo {
    local REPORTTIME=-1
    FILE=$(locate-git-repos-and-status | tac | fzf --exact --no-sort --cycle --ansi --no-mouse --with-nth=2.. | cut -f1) && [[ -d $FILE ]] && commandline-execute "cd $FILE"
}
zle -N _goto-git-repo
bindkey "^G" _goto-git-repo # goto git repo

####### Search-in-files -- search filenames and file contents, open accepted file in editor (at selected line) #######
function _ls-files-git-with-status {
        #ST=" (modified:$NUM)"
        #ST="\e[0;31m$ST\e[0m"
    FILT="(^|/)\.?[^\.^/]+($|\.txt$)"
    GITROOTDIR=$(git rev-parse --show-toplevel 2>/dev/null) && \
    GITFILES=$(git ls-files $GITROOTDIR --exclude-standard | /bin/grep -Fxvf  <(git config --file .gitmodules --name-only --get-regexp path | cut -d '.' -f2-2) ) && \
    GITFILES=$({ echo $GITFILES | /bin/rg -e $FILT ; echo $GITFILES | /bin/rg -ve $FILT}) && \
    MODIFIED=$(git status --untracked-files=no | grep -e "\t." | sed -E 's@\t(.*): *@  \\e[0;31m(\1)\\e[0m  @' | sort -r | uniq) && \
    UNMODIFIED=$(/bin/grep -Fvxf <(git ls-files $GITROOTDIR --modified --exclude-standard) <(echo $GITFILES) | sed 's/^/    /' | tac) && \
    {echo $MODIFIED ; echo $UNMODIFIED} | grep . --color=never
}
function _ls-files-git {
    _ls-files-git-with-status | awk -F ' ' '{print $NF}' | tr -d ' '
}
function _search-and-edit-file-git {
    local REPORTTIME=-1
    FILE=$(_ls-files-git-with-status | fzf --exact --no-sort --cycle | awk -F ':' '{print $NF}' | tr -d ' ') && \
    [[ -n $FILE ]] && commandline-execute "$EDITOR $FILE"
}

function _search-and-edit-line-git {
    local REPORTTIME=-1
    export TEMP=$(mktemp -u)
    trap 'rm -f "$TEMP"; unset TEMP2' EXIT

    PREVIEW='FILE=$(echo {1} | awk '\''{print $NF}'\''); [ -z {2} ] && LINE=0 || LINE={2}; '
    [ $(command -v bat) ] && PREVIEW=$PREVIEW' bat --color=always $FILE --highlight-line $LINE' || PREVIEW=$PREVIEW' less $FILE'

    RG_CMD='rg --color=always --colors \"match:none\" --smart-case'

    DIR=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -z $DIR ]; then
        DIR=$PWD
        #GET_FILES_IN_DIR='Q=%q; locate --existing --database=\$HOME/.locate.db \"\$PWD/*\$Q*\" | rg -v \"/[\\.|_]\" | while IFS= read -r line; do [[ -f \"\$line\" && ! -x \"\$line\" ]] && echo \"\$line\"; done'
        GET_FILES_IN_DIR='Q=%q ; fd -t f -i \"\$Q\" | '$RG_CMD' \"\$Q\"'
    else
        cd $DIR
        export TEMP2=$(_ls-files-git-with-status)
        GET_FILES_IN_DIR='echo \$TEMP2 | '$RG_CMD' %q'
    fi

    TR_CHANGE='rg_pat={q:1}      # The first word is passed to ripgrep
    fzf_pat={q:1..}   # The rest are passed to fzf
    if ! [[ -r "$TEMP" ]] || [[ $rg_pat != $(cat "$TEMP") ]]; then
        echo "$rg_pat" > "$TEMP"
        if [ ! -z "$rg_pat" ]; then
            printf "+reload:sleep 0.1; { '$GET_FILES_IN_DIR' ; '$RG_CMD' --column --line-number --no-heading --sort-files %q } || true;" "$rg_pat" "$rg_pat"
        elif [ ! -z $(git rev-parse --show-toplevel 2>/dev/null) ]; then
            printf "+reload:sleep 0.1; { '$GET_FILES_IN_DIR' } || true;" "$rg_pat"
        else
            printf "+reload:sleep 0.1; echo \":not a git repo: \"$PWD ;"
        fi
    fi
    echo "+search:$fzf_pat"'

    TR_RESIZE='if (( FZF_LINES > 18 && (FZF_COLUMNS < 5*FZF_LINES || FZF_COLUMNS <= 150) )); then; echo "change-preview-window:up,50%,border-bottom"
    elif (( FZF_COLUMNS > 150 )); then; echo "change-preview-window:right,50%,border-left";
    else echo "+change-preview-window:hidden"; fi'

    FR=$(fzf --ansi --exact --smart-case --cycle --no-sort --no-mouse \
        --color "hl:-1:underline:bold,hl+:-1:underline:reverse" \
        --with-shell 'zsh -c' \
        --preview $PREVIEW \
        --preview-window 'hidden,+{2}+3/3,~3' \
        --bind 'start,change:transform:'$TR_CHANGE \
        --bind 'focus,resize:transform:'$TR_RESIZE \
        --nth -1 \
        --expect=ctrl-e,enter \
        --delimiter : \
    )
    KEY=$(echo $FR | awk 'NR==1{print $1}' | tr -d " ")
    FILE=$(echo $FR | awk 'NR==2{print $0}' | awk -F ':' '{print $1}' | awk '{print $NF}' | tr -d " ")
    LINE=$(echo $FR | awk 'NR==2{print $0}' | awk -F ':' '{print $2}' | tr -d " ")
    [ -z $FILE ] && return
    if [[ $KEY == "enter" ]]; then
        if [ -z $LINE ]; then
            commandline-execute "$EDITOR $DIR/$FILE"
        else
            print -s "$EDITOR $DIR/$FILE"
            commandline-execute " $EDITOR $DIR/$FILE +$LINE"
        fi
    else
        zle kill-whole-line && zle -U $DIR/$FILE
    fi
}
zle -N _search-and-edit-line-git
bindkey "^F" _search-and-edit-line-git # search-in-files

############## Reverse history search ################
function _reverse-history-search {
    local REPORTTIME=-1
    LINE=$(fc -lnr 0 | fzf --exact --no-sort --bind=ctrl-e:accept) && \
        zle kill-whole-line && zle -U $LINE
}
zle -N _reverse-history-search
bindkey "^R" _reverse-history-search # Ctrl-R reverse history search

###### replicate bash behaviour for IGNOREEOF on ctrl-d #########
setopt ignore_eof
function _bash-ctrl-d() {
    if [[ $CURSOR == 0 && -z $BUFFER ]]
    then
        [[ -z $IGNOREEOF || $IGNOREEOF == 0 ]] && exit
        if [[ "$LASTWIDGET" == "_bash-ctrl-d" ]]
        then
            (( --__BASH_IGNORE_EOF <= 0 )) && exit
        else
            echo "Press ctrl-d again to exit... (IGNOREEOF:$IGNOREEOF)"
            (( __BASH_IGNORE_EOF = IGNOREEOF ))
        fi
    fi
}
zle -N _bash-ctrl-d
bindkey "^D" _bash-ctrl-d

###################################################################
#### start background jobs on init (update plocate, gitindex) #####
###################################################################

function _zsh-background-init {
    /usr/bin/updatedb --require-visibility 0 -o $HOME/.locate.db --prune-bind-mounts no
    locate-git-repos-and-status
}
function _zsh-background-init-fork {
    _zsh-background-init &
}

ZCACHE_LAST_BG_INIT=$ZSH/last_bg_init
[ -f $ZCACHE_LAST_BG_INIT ] && LAST_BG_INIT=$(<$ZCACHE_LAST_BG_INIT)
if [ -z $LAST_BG_INIT -o $(( $(date +%s) > $LAST_BG_INIT+3600 )) -eq 1 ]; then
    echo $(date +%s) > $ZCACHE_LAST_BG_INIT
    _zsh-background-init-fork > /dev/null 2>&1
fi

# activate python venv if exists
[[ -d ~/.venv/venv ]] && source ~/.venv/venv/bin/activate
