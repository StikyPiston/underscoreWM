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
`|| Startup and Onboarding apps\n
ras alacritty\n
rafb alacritty -e micro ~/.config/underscore/conf.fig\n
\n
|| Keybindings\n
bind Mod4+Return; alacritty\n
bind Mod4+Return; wofi --show drun\n
\n
|| Backdrop and misc stuff and things :D\n
bgd ~/.config/underscore/default.png`

## have fun!
