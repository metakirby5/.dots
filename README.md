dotfiles
========

All of my dotfile configs.

## TODO

- vimrc statusline colors
- Look at i3 on archwiki, j4tools, i3-extras
- Colorscheme generator
- Lock on laptop lid close
- Customize ncmpcpp
- Customize ranger
- move to lemonbar/candybar/i3blocks?
- move to termite?

## Dependencies

### Fonts
- Source Code Pro
- tewi

### Packages
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
- mpd
- mpc
- mpv
- ncmpcpp
- ranger
- scrot
- jomo/imgur-screenshot
- dropbox
- nmtui
- xflux

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

