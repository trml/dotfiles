#!/bin/bash
.PHONY: help _post-install install-home install-root restore-files remove-files status update
help:
	@echo "Manage dotfiles with GNU stow and git"
	@echo " Usage:"
	@echo "  make <target>"
	@echo " Targets:"
	@echo "  install-home   Stow dotfiles in the home directory"
	@echo "  restore-home   Unstow and restore files to their original location"
	@echo "  remove-home    Unstow and remove the files without restoring them"
	@echo "  install-root   Stow dotfiles in /, e.g /usr and /etc"
	@echo "  restore-root"
	@echo "  remove-root"
	@echo "  status"

_TARGETHOME=$(HOME)
_STOWHOME=$(CURDIR)/home/
_TARGETROOT=/
_STOWROOT=$(CURDIR)/root/

./antigen/antigen.zsh:
	git submodule update --init --recursive
./zaw/zaw.zsh:
	git submodule update --init --recursive

_post-install:
	@echo "The target files will be adopted by stow but not commited. Use 'git diff' to see the changes, 'git commit' to keep the original files, 'git checkout HEAD' to overwrite the old files."

install-home: antigen/antigen.zsh zaw/zaw.zsh _post-install
ifneq ($(SUDO_COMMAND),)
	@echo "This command must be run without sudo."
else
	cd $(_STOWHOME) && stow --dir=$(_STOWHOME) --target=$(_TARGETHOME) --adopt *
	cd $(_STOWHOME) && stow --dir=$(_STOWHOME) --target=$(_TARGETHOME) --restow *
endif

install-root: _post-install
	cd $(_STOWROOT) && stow --dir=$(_STOWROOT) --target=$(_TARGETROOT) --adopt *
	cd $(_STOWROOT) && stow --dir=$(_STOWROOT) --target=$(_TARGETROOT) --restow *

restore-home:
ifneq ($(SUDO_COMMAND),)
	@echo "This command must be run without sudo."
else
	./functions-sh --restore-files $(_TARGETHOME) $(_STOWHOME)
endif

restore-root:
	./functions-sh --restore-files $(_TARGETROOT) $(_STOWROOT)

remove-home:
ifneq ($(SUDO_COMMAND),)
	@echo "This command must be run without sudo."
else
	cd $(_STOWHOME) && stow --dir=$(_STOWHOME) --target=$(_TARGETHOME) --delete *
endif

remove-root:
	cd $(_STOWROOT) && stow --dir=$(_STOWROOT) --target=$(_TARGETROOT) --delete *

status:
	@echo "Managed files:"
	@./functions-sh --show-managed-files $(_TARGETHOME) $(_STOWHOME)
	@./functions-sh --show-managed-files $(_TARGETROOT) $(_STOWROOT)
	@echo "Unlinked files (* = existing files):"
	@./functions-sh --show-unlinked-files $(_TARGETHOME) $(_STOWHOME)
	@./functions-sh --show-unlinked-files $(_TARGETROOT) $(_STOWROOT)
	@echo "Dead symlinks:"
	@./functions-sh --show-dead-symlinks $(_TARGETHOME) $(_STOWHOME)
	@./functions-sh --show-dead-symlinks $(_TARGETROOT) $(_STOWROOT)
