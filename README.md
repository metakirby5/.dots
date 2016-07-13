.dots
=====

All of my dotfiles.

![OS X preview](https://ptpb.pw/~aesthetique.png)

Here's what you'll need...

## Software

### All platforms

- GNU Stow
- metakirby5/whizkers
- metakirby5/scripts (somewhat optional)
- Packages from language-specific managers (`~/.pipfile`, `~/.npmfile`, etc.)

### OS X

- Xcode
- brew
- Everything in `osx/.Brewfile`
- Everything in `osx/.appstorefile`
- rgrove/textual-sulaco
- XVimProject/XVim (hopefully on brew soon)

### Linux

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

## Fonts

### OS X

- System fonts.

### Linux

- Calibri
- [PixelMPlus12](https://osdn.jp/projects/mix-mplus-ipa/releases/58930)
- [Source Code Pro](https://github.com/adobe-fonts/source-code-pro)
- [M+ 1p](http://mplus-fonts.osdn.jp/mplus-outline-fonts/download/)
- [Baekmuk Gulim](http://www.freekoreanfont.com/baekmuk-gulim-download/)

## Browsers

### Userscripts

- ccd0/4chan-x
- nebukazar/StyleChan

### Safari

- tampermonkey
- flipxfx/sVim
- chrisaljoudi/ublock
- com.searchpreview
- com.sidetree.HoverZoom

### Chrome

Theme in `~/.whizkers_output/chrome_theme/`.

For OS X, use the system theme.

[Dark Red Dark](https://chrome.google.com/webstore/detail/dark-red-dark/blhnkflbilekjahkjkkjchfkkhgcnfjj) is another option.

## Installation

### All platforms

- Clone this repo into `~/.dots`.
- Add `source ~/.posixrc` to the appropriate files
  (`~/.bashrc` and `~/.bash_profile`)
- Follow platform-specific instructions.
- Install packages from language-specific managers.
  - You can also try using `install-leaves` instead.
- Install browser extensions/themes.
- If you want, copy over `misc/root_bashrc.sh` to your root's
  home directory (to the appropriate file) and symlink the `.vimrc`.
- Reboot.

### Language-specific package managers

- Python: `xargs pip install --upgrade < ~/.pipfile`
- Node: `xargs npm install -g < ~/.npmfile`

### OS X

- Install Xcode from the App Store.
- Import the `Terminal.app` profile in `misc/terminal/Japanesque.terminal`.
- Install `brew` from [brew.sh](http://brew.sh/).
- Install `stow` using `brew`.
- `cd ~/.dots`
- `stow base osx`
- `source ~/.bashrc`
- `brew bundle --global`
- Install `whizkers` via `pip` and use it to choose a colorscheme.
- `yes | osx-set-defaults`
- Tweak whatever other settings you want in Preferences.app.
- Install the apps in `~/.appstorefile`.

### Linux

- Install all the dependencies you need with your favorite package
  manager. You really need `stow` and `whizkers`.
- `cd ~/.dots`
- `stow base linux`
- If you are using i3:
  - `stow i3`
  - Ensure you are using `i3init` to start i3.
- `source ~/.bashrc`
- Ensure your profile is called `profile` so the templates in
  `~/.mozilla/firefox/profile` can render properly.
- Use `whizkers` and choose a colorscheme.
- Install *Stylish* for Chrome/Firefox and install the relevant userstyles
  from `~/.whizkers_output/userstyles`.
- Set up oomox and use the file in `~/.whizkers_output/oomox.sh`.

## Maintenance

- Regularly pull and `restow-dots` to keep up-to-date.
- Regularly `dump-leaves` to export dependencies.

## TODO

- [ ] Fix whizkers files to allow light colorschemes
- [ ] Stick XVimProject/XVim on brew
