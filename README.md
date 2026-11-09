# ZSH Config

Zsh configuration stored in `~/.config/zsh`, with `.zshrc` as the main
interactive-shell loader.

## Structure

```text
~/.config/zsh/
├── .gitignore
├── .zshenv                         # Environment setup for Zsh sessions
├── .zshrc                          # Interactive startup and loading order
├── env.zsh                         # Application variables and personal paths
├── bookmarks.zsh                   # Named directory bookmarks
├── binds.zsh                       # Custom bindings and vi-mode callbacks
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
2. `plugins/manual.zsh`, once per shell. This loads Deja, syntax highlighting,
   the Powerlevel10k theme, and zsh-vi-mode.
3. `integrations/init.zsh`. FZF settings and VPN aliases refresh on reload;
   zoxide, FZF widgets, mise, direnv, and opam initialize once per shell when
   available.
4. `prompt/init.zsh` on initial startup. This loads `p10k.zsh`, which sources
   `prompt-code.zsh` and uses the neighboring `p10k-code.toml` for project metadata.
5. The bookmark-aware `cd` function and `binds.zsh`.

The directory entry points are `aliases/init.zsh`, `integrations/init.zsh`, and
`prompt/init.zsh`. Plugin selection is controlled directly in `.zshrc`.
Only one plugin loader and one rclone implementation should be active at a time.
Scripts under `tools/` run when requested; they are not sourced during startup.
