# .dotfiles


## Extra Setup

Iterm2 profile

```
We'll have to manually load this config file into Iterm. Also set Preferences -> Appearance -> General -> Theme = Compact or Minimal
https://apple.stackexchange.com/a/293988
Install fonts using: https://github.com/ryanoasis/nerd-fonts#option-4-homebrew-fonts so that nvim icons show up correctly
```

VS Code Extensions

```
Before onboarding, run: code --list-extensions > <src>, then onboard to dotfiles. After releasing this dotfile, install the extensions with: cat <src> | xargs -L 1 echo code --install-extension
https://stackoverflow.com/a/49398449
```

VS Code User Settings

```
https://stackoverflow.com/questions/39972335/how-do-i-press-and-hold-a-key-and-have-it-repeat-in-vscode
```

Grafana config file

```
Copy the (symlinked) config to /opt/homebrew/etc/grafana/grafana.ini as another symlink
```

## Resources

- [~/.dotfiles in 100 Seconds](https://www.youtube.com/watch?v=r_MpUP6aKiQ)
- [GNU Stow](https://www.gnu.org/software/stow/manual/stow.html)
