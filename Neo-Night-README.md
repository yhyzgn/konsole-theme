# Neo-Night Konsole bundle

Neo-Night is the dark counterpart to Neo-Light. It keeps the same Konsole
profile behavior while mapping ANSI colors to the IDEA Dark and One Dark palette
found under `idea/colors/`.

## Contents

- `Neo-Night.profile`: animated and blinking cursor, mouse tracking, wheel zoom,
  alternate-screen scrolling, link handling, and semantic terminal hints.
- `Neo-Night.colorscheme`: dark IDEA-derived ANSI palette.
- `install-neo-night.sh`: installs Neo-Night for the current user and makes it
  the default Konsole profile.
- `uninstall-neo-night.sh`: restores any replaced Neo-Night files and the
  previous default-profile setting.

The bundle does not set a shell command, font, or oh-my-posh configuration, so
the target computer's existing shell startup remains in control.

## Install

```sh
chmod +x install-neo-night.sh uninstall-neo-night.sh
./install-neo-night.sh
```

## Uninstall

```sh
./uninstall-neo-night.sh
```

The scripts use `${XDG_DATA_HOME:-$HOME/.local/share}/konsole` and
`${XDG_CONFIG_HOME:-$HOME/.config}/konsolerc`. Existing same-name files and the
previous default Profile are preserved under
`~/.local/share/konsole/.neo-night/` until uninstall.

Restart Konsole or open a new tab after installation to reload the profile
list.
