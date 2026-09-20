# Neo Konsole Themes

Portable Light and Night profiles for KDE Konsole, distilled from the IDEA
color schemes under [`idea/`](idea/). Both profiles preserve the target
machine's shell, font, and oh-my-posh configuration.

## Themes

- **Neo-Light**: a clear light palette based on the IDEA Emacs and Light colors.
- **Neo-Night**: a high-contrast dark palette based on IDEA Dark and One Dark.

Both profiles enable animated cursor rendering, mouse tracking, wheel zoom,
alternate-screen scrolling, link handling, and semantic terminal hints.

## Install

Install either theme for the current user and make it the default profile:

```sh
./install-neo-light.sh
# or
./install-neo-night.sh
```

No root access is required. The scripts honor `XDG_DATA_HOME` and
`XDG_CONFIG_HOME`, and save the previous same-name files and default profile so
they can be restored during uninstall.

## Uninstall

```sh
./uninstall-neo-light.sh
# or
./uninstall-neo-night.sh
```

See [Neo-Light-README.md](Neo-Light-README.md) and
[Neo-Night-README.md](Neo-Night-README.md) for theme-specific details.

## Isolate a full-screen command when needed

Some remote menu systems draw directly into the terminal's primary screen and
do not clear it when they exit. Install the optional Bash helpers:

```sh
./install-session-cleanup.sh
source ~/.bashrc
```

Normal prompts, Enter handling, scrollback, and `ssh` are not modified. Run a
known full-screen command in Konsole's alternate screen explicitly:

```sh
neo_screen command [argument ...]
neo_ssh user@host
```

When that command exits, Konsole restores the screen that was visible before
it started. Its output is intentionally not added to scrollback, so use the
ordinary command instead whenever its output should remain visible. Automatic
prompt-time cleanup is deliberately avoided because a shell cannot reliably
distinguish stale full-screen content from normal command output.

Remove the integration with:

```sh
./uninstall-session-cleanup.sh
```
