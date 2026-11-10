# ZSH Config

Zsh configuration stored in `~/.config/zsh`, with `.zshrc` as the main
interactive-shell loader.

## Set the configuration directory through `/etc/zshenv`

Place this repository at `~/.config/zsh`. Zsh reads its system-wide environment
file before personal startup files, so set `ZDOTDIR` there. This selects the
configuration directory, not the terminal's working directory.

Edit the system file, preserving its existing contents:

```sh
sudoedit /etc/zshenv
```

Some installations use `/etc/zsh/zshenv` instead; edit the file your installation
actually loads. Add this block once, or update the existing directory-selection
block:

```zsh
if [[ -z "$XDG_CONFIG_HOME" ]]; then
  export XDG_CONFIG_HOME="$HOME/.config"
fi

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]; then
  export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi
```

With the default XDG location, Zsh loads `~/.config/zsh/.zshenv` and, for
interactive shells, `~/.config/zsh/.zshrc` automatically. An existing
`XDG_CONFIG_HOME` selects its `zsh` subdirectory instead.

Check discovery without inheriting the current `ZDOTDIR`:

```sh
env -u ZDOTDIR zsh -c 'print -r -- "$ZDOTDIR"'
# Expected with the default XDG location: /home/your-user/.config/zsh
```

Then restart the current shell:

```sh
exec zsh
```

See the [Zsh startup-file documentation](https://zsh.sourceforge.io/Doc/Release/Files.html).

## Structure

```text
~/.config/zsh/
├── .gitignore
├── .zshenv                         # Environment setup for Zsh sessions
├── .zshrc                          # Interactive startup and loading order
├── env.zsh                         # Application variables and personal paths
├── bookmarks.zsh                   # Named directory bookmarks
├── binds.zsh                       # Built-in vi mode and custom bindings
├── README.md
├── LICENSE
│
├── aliases/
│   ├── init.zsh                    # Loads the selected alias modules
│   ├── shell-shortcuts.zsh
│   ├── filesystem-helpers.zsh
│   ├── system-helpers.zsh
│   ├── application-shortcuts.zsh
│   ├── rcaliases.zsh               # Alternative rclone implementation
│   └── rcaliases-pretty.zsh        # Selected rclone implementation
│
├── plugins/
│   ├── manual.zsh                  # Selected plugin loader
│   └── zinit.zsh                   # Alternative plugin loader
│
├── integrations/
│   ├── init.zsh                    # Reloadable settings and one-time hooks
│   ├── fzf.zsh
│   ├── direnv.zsh
│   └── tifr-vpn.zsh
│
├── prompt/
│   ├── init.zsh                    # Loads personal prompt settings
│   ├── p10k.zsh                    # Powerlevel10k configuration
│   ├── prompt-code.zsh             # Project metadata rendered by Powerlevel10k
│   └── p10k-code.toml              # Starship project-metadata configuration
│
├── apps/
│   ├── eza/
│   │   └── ignore
│   └── git/
│       ├── config
│       └── ignore
│
├── tools/
│   ├── rclone/
│   │   └── rclone-format.py        # Formats rclone JSON listings
│   └── tlconf/
│       ├── tlconf.awk
│       ├── tlconf-simple.awk
│       ├── tlconf-theme.awk
│       ├── tlconf-view.awk
│       └── tlconf-view.zsh         # Standalone interactive viewer
│
└── docs/
    └── rclone/
        ├── index.txt
        ├── general.txt
        ├── listings.txt
        ├── storage.txt
        ├── mounts.txt
        ├── transfers.txt
        └── comparisons.txt
```

## Loading order

`.zshenv` sets platform flags, XDG directories, editor and pager settings, and
PATH, then sources `env.zsh`.

For interactive shells, `.zshrc` handles GPG, pfetch, the initial direnv
environment, Powerlevel10k instant prompt, history, and shell options. It then
loads:

1. `aliases/init.zsh` and `bookmarks.zsh`.
2. `plugins/manual.zsh`, once per shell. This loads completions, the Powerlevel10k
   theme, and the deferred plugin loader.
3. `integrations/init.zsh`. FZF settings and VPN aliases refresh on reload;
   zoxide, FZF widgets, mise, direnv, and opam initialize once per shell when
   available.
4. `prompt/init.zsh` on initial startup. This loads `p10k.zsh`, which sources
   `prompt-code.zsh` and uses the neighboring `p10k-code.toml` for project metadata.
5. The bookmark-aware `cd` function and `binds.zsh`, which enables Zsh's built-in
   vi mode with `bindkey -v` and a 0.1-second Escape timeout (`KEYTIMEOUT=10`).
   The cursor is a block in normal mode and a vertical bar in insert mode;
   the terminal's default cursor is restored when running a command.
6. `plugins/deferred.zsh` once the shell is waiting for input. This loads FZF-tab,
   FZF-git, autosuggestions, colored man pages, and syntax highlighting.

The directory entry points are `aliases/init.zsh`, `integrations/init.zsh`, and
`prompt/init.zsh`. Plugin selection is controlled directly in `.zshrc`.
Only one plugin loader and one rclone implementation should be active at a time.
Scripts under `tools/` run when requested; they are not sourced during startup.

## Benchmark

Measured interactively _on login_ with [zsh-bench](https://github.com/romkatv/zsh-bench)

| Metric            |     Result |
| ----------------- | ---------: |
| First prompt lag  |  17.738 ms |
| First command lag | 119.619 ms |
| Command lag       |  21.703 ms |
| Input lag         |   2.936 ms |
| Exit time         |  64.081 ms |
