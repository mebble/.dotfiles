# .dotfiles

## Setup

```sh 
make start
```

### Extra Setup

Iterm2 profile

- We'll have to manually load the config file into Iterm.
- Set Preferences -> Appearance -> General -> Theme = Compact or Minimal
- Set Preferences -> Appearance -> Windows -> Hide scrollbars = True
- Set Preferences -> General -> Selection -> Applications in terminal may access clipboard = True
- See https://apple.stackexchange.com/a/293988

## Onboard

Some dotfiles need to updated manually after a certain change has been made to the system. This section describes how to update them.

_Note: Do not replace the files because they are symlinks. Write to them instead_

Brewfile

```sh
pushd ~/.config/brew/
brew bundle dump --describe --file=Brewfile.temp
cat Brewfile.temp > Brewfile
rm Brewfile.temp
popd
```

VSCode

```sh 
code --list-extensions > ~/Library/Application\ Support/Code/User/extensions.txt
```

Iterm2 profile

- Go to Settings -> Profiles -> Other Actions -> Save Profile as JSON
- Open the output file in vim and run `:%!jq -S`
- Run `cat <output> > ~/.config/iterm2/profile.json`

## Resources

- [~/.dotfiles in 100 Seconds](https://www.youtube.com/watch?v=r_MpUP6aKiQ)
- [GNU Stow](https://www.gnu.org/software/stow/manual/stow.html)
- [ThePrimeagen/.dotfiles](https://github.com/ThePrimeagen/.dotfiles)
