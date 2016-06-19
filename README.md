.dots
=====

All of my dotfile configs.

## Dependencies

### Fonts

- Calibri
- [PixelMPlus12](https://osdn.jp/projects/mix-mplus-ipa/releases/58930)
- [Source Code Pro](https://github.com/adobe-fonts/source-code-pro)
- [M+ 1p](http://mplus-fonts.osdn.jp/mplus-outline-fonts/download/)
- [Baekmuk Gulim](http://www.freekoreanfont.com/baekmuk-gulim-download/)

### Packages

All systems will need:
- GNU Stow
- metakirby5/whizkers
- metakirby5/bash-scripts (somewhat optional)

#### Linux

- metakirby5/lemonblocks
- rxvt-unicode-256color
- tmux
- Airblader/i3-gaps
- krypt-n/bar
- gstk/siji
- acrisci/i3ipc-python
- eBrnd/i3lock-color
- xautolock
- chjj/compton
- melek/dmenu2
- enkore/j4-dmenu-desktop
- ffmpeg
- imagemagick
- jq
- dunst + dunstify
- notify-send
- feh
- conky
- mpd and/or mopidy
- mpc
- mpv
- ncmpcpp
- ranger
- scrot
- dropbox
- nmtui
- xflux
- unclutter
- actionless/oomox
- gtk-reload (from neeasade/autotheme.sh)
- devmon

#### Mac

- brew (most dependencies are in ~/.Brewfile)

### Chrome Theme

[Dark Red Dark](https://chrome.google.com/webstore/detail/dark-red-dark/blhnkflbilekjahkjkkjchfkkhgcnfjj)
or the one found in `~/.whizkers_output/chrome_theme/`.

For Mac, I use the system theme.

## Installation

### All platforms

- Clone this repo into `~/.dots`.
- Add `source ~/.posixrc` to the appropriate files
  (`~/.bashrc` or `~/.bash_profile`)
- Follow platform-specific instructions.
- If you want, copy over `misc/root_bashrc.sh` to your root's
  home directory (to the appropriate file) and symlink the `.vimrc`.
- Reboot.

### Linux

- Install all the dependencies you need with your favorite package
  manager. You really need `stow` and `whizkers`.
- `cd ~/.dots`
- `stow base linux`
- If you are using i3:
  - `stow i3`
  - Ensure you are using `i3init` to start i3.
- Ensure your profile is called `profile` so the templates in
  `~/.mozilla/firefox/profile` can render properly.
- Use `whizkers` and choose a colorscheme.
- Install *Stylish* for Chrome/Firefox and install the relevant userstyles
  from `~/.whizkers_output/userstyles`.
- Set up oomox and use the file in `~/.whizkers_output/oomox.sh`.

### Mac

- Import the `Terminal.app` profile in `misc/terminal/Japanesque.terminal`.
- Install `brew` from [brew.sh](http://brew.sh/).
- Install `stow` using `brew`.
- `cd ~/.dots`
- `stow base mac`
- `brew bundle --global`
- Install `whizkers` via `pip` and use it to choose a colorscheme.
- Tweak whatever settings you want in Preferences.app.

## TODO

- Fix whizkers files to allow light colorschemes
