# Neo-Light Konsole bundle

This directory is a portable export of the Neo-Light Konsole configuration
distilled from the IDEA theme files under `idea/`.

## Contents

- `Neo-Light.profile`: Konsole profile with animated and blinking cursor, mouse
  tracking, wheel zoom, alternate-screen scrolling, link handling, and semantic
  terminal hints enabled.
- `Neo-Light.colorscheme`: the IDEA-derived Light ANSI palette.
- `install-neo-light.sh`: installs the profile for the current user and makes it
  the default Konsole profile.
- `uninstall-neo-light.sh`: removes the installed Neo-Light files and restores
  the previous Profile files and default-profile value.

The bundle intentionally does not contain a shell command, font override, or
oh-my-posh configuration. Existing shell startup and oh-my-posh setup therefore
continue to work on the target computer.

## Install on another computer

Copy the four bundle files to a directory, then run:

```sh
chmod +x install-neo-light.sh uninstall-neo-light.sh
./install-neo-light.sh
```

The scripts use `${XDG_DATA_HOME:-$HOME/.local/share}/konsole` and
`${XDG_CONFIG_HOME:-$HOME/.config}/konsolerc`, so they work with standard KDE
user paths and do not require root access. Existing files are backed up in
`~/.local/share/konsole/.neo-light/` until uninstall.

To undo the installation:

```sh
./uninstall-neo-light.sh
```

Restart Konsole or open a new tab after installation to load the profile list.
