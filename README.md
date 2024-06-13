# underscoreWM
A simple X11 window manager written in Lua by yours truly.

## Installation
In most desktops, you can double-click the ".deb" file to install it.
If you want to install it via the terminal, run; `dpkg -i ./underscoreWM.deb`

## Configuration
The Window Manager's config is located at `~/.config/underscore/conf.fig`
There are various keywords to configure the WM.

`rafb` runs a command at first boot.
`ras` runs a command at startup.
`bind` binds keys to a command.
`bgd` sets the background
`||` is for a comment.

**Default Config**
`|| Startup and Onboarding apps
ras alacritty
rafb alacritty -e micro ~/.config/underscore/conf.fig

|| Keybindings
bind Mod4+Return; alacritty
bind Mod4+Return; wofi --show drun

|| Backdrop and misc stuff and things :D
bgd ~/.config/underscore/default.png`

## have fun!
