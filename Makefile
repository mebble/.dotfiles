start:
	@echo 'Install brew through curl script found at'
	@echo 'https://brew.sh/'
	@echo
	@echo 'Then run `make install`'

install:
	brew bundle --file ~/.dotfiles/.config/brew/Brewfile
	@echo
	@echo 'Now run `make install-manual`'

install-manual:
	@echo 'Install other programs through curl script'
	@echo 'https://github.com/nvm-sh/nvm'
	@echo 'https://deno.com/'
	@echo 'https://sdkman.io/'
	@echo 'https://ohmyz.sh/'
	@echo
	@echo 'Install oh-my-zsh stuff'
	@echo 'https://github.com/romkatv/powerlevel10k#oh-my-zsh'
	@echo 'https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md#oh-my-zsh'
	@echo
	@echo 'Install tmux stuff'
	@echo 'https://github.com/tmux-plugins/tpm'
	@echo
	@echo 'Install other programs'
	@echo 'Karabiner Elements'
	@echo 'VS Code'
	@echo 'Google Chrome'
	@echo 'Obsidian'
	@echo 'Sublime Merge'
	@echo 'iTerm2'
	@echo
	@echo 'Then run `make release`'

release:
	@echo 'Releasing dotfiles'
	stow -d ~/.dotfiles/ -t ~/ -S .
	stow -d ~/.dotfiles/ -t ~/ -S personal
	@echo
	@echo 'Releasing dotfiles outside of ~/'
	cp -P ~/.config/grafana/grafana.ini /opt/homebrew/etc/grafana/grafana.ini
	@echo
	@echo 'Performing final steps'
	# https://stackoverflow.com/a/44010683
	defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
	# https://stackoverflow.com/a/49398449
	cat ~/Library/Application\ Support/Code/User/extensions.txt | xargs -L 1 echo code --install-extension
