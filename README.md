# Zsh Config

A modular Zsh setup for daily terminal work, stored in `~/.config/zsh`.
Powerlevel10k handles the prompt; a small Git-based loader manages plugins.

## Features

- Catppuccin Mocha prompt with Git status, command duration, and vi-mode state.
- Asynchronous Starship project metadata, cached for two seconds and rendered
  as one coding segment.
- Built-in vi editing: block cursor in normal mode, bar cursor in insert mode,
  and a 0.1-second Escape timeout.
- FZF file, history, and directory search; searchable Tab completion;
  history-based autosuggestions; Patina syntax highlighting.
- Zoxide navigation, direnv integration, and discovery of existing Python
  `.venv` environments.
- Cached completion and initialization scripts, deferred optional plugins,
  and explicit plugin updates.

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
├── .zshenv                 # XDG directories, editor, PATH, and env.zsh
├── .zshrc                  # History, startup order, and named directories
├── env.zsh                 # Personal variables and application paths
├── binds.zsh               # Native vi mode, cursor shapes, and shortcuts
├── aliases/                # Shell, file, system, package, and app shortcuts
├── plugins/
│   ├── manual.zsh          # Active loader, completions, and Powerlevel10k
│   ├── deferred.zsh        # Optional plugins loaded when ZLE is idle
│   └── zinit.zsh           # Alternative loader; inactive by default
├── integrations/           # FZF, direnv, SSH banner, and VPN helpers
├── prompt/                 # Powerlevel10k theme and async Starship bridge
├── apps/                   # Companion application configs
├── tools/                  # Standalone rclone and TeX Live helpers
└── docs/rclone/            # Rclone reference notes
```

Startup order: environment → instant prompt and history → aliases and functions
→ core plugins → integrations → prompt settings → keybindings → deferred plugins.
Named directories such as `~hl` and `~res` are defined in `.zshrc`.

## Plugins

| Component | Purpose |
| --- | --- |
| [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | Prompt, instant prompt, and Git status |
| [ez-compinit](https://github.com/mattmc3/ez-compinit) | Cached completion initialization |
| [zsh-completions](https://github.com/zsh-users/zsh-completions) | Additional completion definitions |
| [zsh-defer](https://github.com/romkatv/zsh-defer) | Deferred plugin initialization |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | Searchable Tab completion |
| [fzf-git](https://github.com/junegunn/fzf-git.sh) | Git search widgets |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Suggestions from history |
| [colored-man-pages](https://github.com/houssamouhra/colored-man-pages) | Man-page colors |
| [zsh-patina](https://github.com/michel-kraemer/zsh-patina) | Syntax highlighting; installed separately |

The active loader clones missing plugins into `~/.local/share/zsh/plugins` on
first use. `plugins/zinit.zsh` is an alternative, not part of normal startup.

## Benchmark

Measured interactively _on login_ with [zsh-bench](https://github.com/romkatv/zsh-bench)
using `--login yes --iters 32` at commit `00311b0`
(refactor(prompt): cache combined project metadata text).

| Metric            |     Result |
| ----------------- | ---------: |
| First prompt lag  |  23.460 ms |
| First command lag | 141.219 ms |
| Command lag       |  12.593 ms |
| Input lag         |   4.284 ms |
| Exit time         |  76.069 ms |
