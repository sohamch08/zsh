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

## Setup

### 1. Install the tools

Install **Zsh, Git, fzf, fd, bat, eza, zoxide, direnv, and Starship** with your
package manager. Use a Nerd Font in your terminal for prompt and file icons.
Install [Patina](https://github.com/michel-kraemer/zsh-patina#how-to-install)
with Cargo; the active configuration calls `~/.cargo/bin/zsh-patina`:

```sh
cargo install --locked zsh-patina
```

Mise, opam, and pfetch have guarded integrations. Aliases for Neovim, lazygit,
yazi, rclone, dust, and batman need those tools when invoked.

### 2. Clone and personalize

For a fresh installation:

```sh
mkdir -p "$HOME/.config"
git clone --branch zsh/minimal https://github.com/sohamch08/zsh.git "$HOME/.config/zsh"
```

Review `env.zsh`, the named directories in `.zshrc`, and `aliases/` for personal
paths and commands. This setup uses the standard `~/.config`, `~/.cache`,
`~/.local/share`, and `~/.local/state` locations.

### 3. Create the initialization caches

Run in Zsh (`zsh -f` starts it without loading this configuration):

```zsh
mkdir -p "$HOME/.cache/zsh/init"
zoxide init --cmd cd zsh > "$HOME/.cache/zsh/init/zoxide.zsh"
direnv hook zsh > "$HOME/.cache/zsh/init/direnv.zsh"
zcompile "$HOME/.cache/zsh/init/zoxide.zsh"
zcompile "$HOME/.cache/zsh/init/direnv.zsh"
```

These files are sourced during startup. Repeat this block after upgrading
zoxide or direnv. Keep the generated files outside Git.

The Python environment helper uses `layout uv`. For a fresh direnv setup:

```sh
mkdir -p "$HOME/.config/direnv"
ln -s "$HOME/.config/zsh/apps/direnv/direnvrc" "$HOME/.config/direnv/direnvrc"
```

For an existing `direnvrc`, merge the supplied `layout_uv` function instead.
The helper discovers existing `.venv` environments and creates and authorizes
its own `layout uv` file; existing `.envrc` files remain under normal direnv
approval. It does not create Python environments or install packages.

### 4. Point Zsh at this directory

Edit the system startup file, preserving its other contents:

```sh
sudoedit /etc/zshenv
```

Some distributions use `/etc/zsh/zshenv`. Add this line to the file Zsh loads:

```zsh
[[ -d "$HOME/.config/zsh" ]] && export ZDOTDIR="$HOME/.config/zsh"
```

Zsh will read this repository's `.zshenv` and `.zshrc` directly. No `.zshrc`
symlink is needed. See [Zsh startup files](https://zsh.sourceforge.io/Doc/Release/Files.html).

### 5. Start and verify

```sh
exec zsh
```

The first interactive start downloads missing plugins. Later starts use local
copies. Verify discovery without inheriting the current `ZDOTDIR`:

```sh
env -u ZDOTDIR zsh -c 'print -r -- "$ZDOTDIR"'
# Expected: /home/your-user/.config/zsh
```

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
FZF reads `apps/fzf/config` directly. Other files under `apps/` are companion
configs to merge or link into each application's configuration directory.

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

## Daily use

| Key | Action |
| --- | --- |
| `Esc` / `i` | Normal mode / insert mode |
| `Ctrl-F` | Search files with FZF |
| `Ctrl-R` | Search command history |
| `Ctrl-O` | Search directories and change directory |
| `Ctrl-K` / `Ctrl-J` | Previous / next line or history entry |
| `Ctrl-L` | Accept the autosuggestion |
| `Ctrl-P` | Save the current input with `push-line` |

The cursor returns to the terminal default while commands run. History lives
in `~/.local/state/zsh/history`.

| Command | Action |
| --- | --- |
| `reload` | Reload aliases, functions, settings, and keybindings |
| `promptreload` | Reload the Powerlevel10k theme and metadata bridge |
| `envreload` | Reload environment variables and paths |
| `fullreload` | Restart Zsh, including plugins and one-time integrations |
| `code-refresh` | Request fresh project metadata |
| `uv-direnv-rescan` | Discover and apply the current Python environment |
| `zplugin-update` | Update cloned plugins with fast-forward pulls |

Use `fullreload` after plugin or integration changes. Regenerate the
[initialization caches](#3-create-the-initialization-caches) after zoxide or
direnv upgrades. Patina activation and `direnv export zsh` remain dynamic.

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

Reproduce with [zsh-bench](https://github.com/romkatv/zsh-bench):

```sh
git clone https://github.com/romkatv/zsh-bench.git "$HOME/zsh-bench"
"$HOME/zsh-bench/zsh-bench" --login yes --iters 32
```

Results depend on the machine and runtime conditions. Patina is not recognized
by this benchmark's highlighting detector; deferred autosuggestions can also
be absent from its initial capability check.

## Credits and license

README organization inspired by [houssamouhra/zsh-config](https://github.com/houssamouhra/zsh-config).
See [LICENSE](LICENSE) for the MIT license.
