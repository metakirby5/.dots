dotfiles
========

All of my dotfile configs.
Also has some Mac stuff.

## TODO

- Make dmenu styling universal
- Move to lemonbar/candybar/i3blocks? OR tint2?
- Move to termite?
- Lock on laptop lid close (xss-lock?)
- Fix whizkers files to allow light colorschemes

## Dependencies

### Fonts
- Calibri
- [Source Code Pro](https://github.com/adobe-fonts/source-code-pro)
- [M+ 1p](http://mplus-fonts.osdn.jp/mplus-outline-fonts/download/)
- [Baekmuk Gulim](http://www.freekoreanfont.com/baekmuk-gulim-download/)

### Packages
- metakirby5/bash-scripts
- metakirby5/whizkers
- rxvt-unicode-256color
- Airblader/i3-gaps
- i3lock
- xautolock
- chjj/compton
- melek/dmenu2
- enkore/j4-dmenu-desktop
- jq
- dunst
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

## Mac
- Slate (soon to be replaced by phoenix or something?)

## Installation
- Install all dependencies.
- Add `.../dotfiles/bin` to your `PATH`.
- Ensure you are using `i3init` to start i3.
- Add `source .../dotfiles/shell/[FILENAME].sh` for the appropriate files.
  For example, for bash:

  ```bash
  source ~/dotfiles/shell/config.sh
  source ~/dotfiles/shell/prompt.sh
  source ~/dotfiles/shell/ls_colors.sh
  ```

- Install *Stylish* for Chrome/Firefox and install the relevant userstyles.
- Run `wzk` and choose a colorscheme.
  Alternatively, manually run `relink-config`, `whizkers`, `xrdb`,
  and restart `i3`.
- Be nice, eat rice.

