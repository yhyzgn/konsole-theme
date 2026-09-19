# Neo-Light for Konsole

This is an independent Konsole Light profile distilled from the IDEA settings in
`../idea`.

## What was extracted

- `idea/options/colors.scheme.xml` selects the `Emacs` scheme. Its light canvas,
  orange selection (`F07746`), forest green base text (`228B22`), indigo
  identifiers/console output (`6565B4`/`6C71C4`), teal types (`2AA198`),
  ochre constants (`B8860B`), purple keywords (`800080`), orange strings
  (`FA6600`), and red/error accents were distilled into the ANSI palette.
- `_@user_Light.icls` contributes the Light scheme's status/error accent family.

The result is deliberately a normal Konsole color scheme rather than a shell
prompt theme. The profile does not set `Command`, `Arguments`, or `Font`, so the
existing shell startup and oh-my-posh initialization remain untouched.

## Install

Copy both files into Konsole's per-user data directory:

```sh
install -Dm644 Neo-Light.colorscheme "$HOME/.local/share/konsole/Neo-Light.colorscheme"
install -Dm644 Neo-Light.profile "$HOME/.local/share/konsole/Neo-Light.profile"
```

Then open Konsole's profile selector and choose **Neo-Light**. If Konsole is
already running, reopen the profile list or start a new tab to reload the files.

The profile keeps animated cursor rendering enabled and leaves mouse tracking,
wheel zoom, alternate-screen scrolling, and link handling enabled for normal
terminal applications.
