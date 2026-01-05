if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -U FISH_EDITOR vi
for name in neovim nvim vim vi nano
	if command -q $name
		set -U FISH_EDITOR $name
		break
	end
end

function commandline-execute; commandline -r $argv && commandline -f execute; end
function ls-git-repos; dirname $(locate "/.git" | rg "/.git\$" | rg -v ".*/\..+/.+*"); end
function goto-git-repo; set -f FILE (ls-git-repos | fzf --exact --no-sort) && commandline-execute "cd $FILE"; end
function search-file-git
	set -f GR $(git rev-parse --show-toplevel 2>/dev/null)
	and set FILE $({ git status --short --untracked-files=no ; comm -13 --nocheck-order (git status --short | cut -d " " -f 3 | psub) (git ls-files $GR | psub) | sed 's/^/   /' } | fzf --exact --no-sort)
	and echo $FILE | cut --complement -c 1-3
end

function search-and-edit-file-git
	set -f FILE (search-file-git) && commandline-execute "$FISH_EDITOR $FILE"
end

# pacman -S fish git fzf fd ripgrep neovim plocate

bind ctrl-f search-and-edit-file-git
bind ctrl-g goto-git-repo

function grep; rg $argv; end
function grem; rg -g '*.{py,m}' $argv; end
function grec; rg -g '*.{c,h,cpp,hpp}' $argv; end
function vim; nvim $argv; end

function sourcesh; source $HOME/.config/fish/config.fish; end
function updatedb; command updatedb --require-visibility 0 -o $HOME/.locate.db --prune-bind-mounts no; end
function locate; command locate --database=$HOME/.locate.db $argv; end






