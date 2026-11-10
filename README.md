# Zsh Config

A modular Zsh setup with a Catppuccin Mocha prompt, fuzzy search, and native vi
editing. Config lives in `~/.config/zsh`; plugins install automatically.

## What you get

| Feature    | Includes                                                                                                                                 |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Prompt     | [Powerlevel10k](https://github.com/romkatv/powerlevel10k), Git status, command duration, async Starship project info                     |
| Vi editing | Block cursor in normal mode, bar in insert mode, 0.1-second Escape timeout                                                               |
| Search     | FZF files/history/directories, [fzf-tab](https://github.com/Aloxaf/fzf-tab), [fzf-git](https://github.com/junegunn/fzf-git.sh)           |
| Typing     | [Autosuggestions](https://github.com/zsh-users/zsh-autosuggestions), [Patina](https://github.com/michel-kraemer/zsh-patina) highlighting |
| Navigation | Zoxide, named directories, direnv, existing Python `.venv` discovery                                                                     |
| Startup    | Instant prompt, cached completions, cached init scripts, deferred plugins                                                                |
| Extras     | Colored man pages, file/system aliases, rclone and TeX Live helpers                                                                      |

## Setup

### 1. Install and clone

Install **Zsh, Git, fzf, fd, bat, eza, zoxide, direnv, and Starship**. Select a
Nerd Font in your terminal. Install Patina with Cargo at the path this config uses:

```sh
cargo install --locked zsh-patina
mkdir -p "$HOME/.config"
git clone --branch zsh/minimal https://github.com/sohamch08/zsh.git "$HOME/.config/zsh"
```

### 2. Prepare the caches and Python layout

Run in Zsh (`zsh -f`):

```zsh
mkdir -p "$HOME/.cache/zsh/init"
zoxide init --cmd cd zsh > "$HOME/.cache/zsh/init/zoxide.zsh"
direnv hook zsh > "$HOME/.cache/zsh/init/direnv.zsh"
zcompile "$HOME/.cache/zsh/init/zoxide.zsh"
zcompile "$HOME/.cache/zsh/init/direnv.zsh"
```

Repeat after upgrading zoxide or direnv. Generated caches stay outside Git.
For a fresh direnv setup, enable the supplied `layout uv` helper:

```sh
mkdir -p "$HOME/.config/direnv"
ln -s "$HOME/.config/zsh/apps/direnv/direnvrc" "$HOME/.config/direnv/direnvrc"
```

For an existing `direnvrc`, add the supplied `layout_uv` function instead. The helper
activates existing `.venv` environments and creates/authorizes its own `.envrc`;
existing `.envrc` files still require normal direnv approval.

### 3. Set the config directory and start

Run `sudoedit /etc/zshenv` (`/etc/zsh/zshenv` on some distributions).
Preserve its contents and add:

```zsh
[[ -d "$HOME/.config/zsh" ]] && export ZDOTDIR="$HOME/.config/zsh"
```

Start Zsh; missing plugins download on the first interactive launch:

```sh
exec zsh
```

Verify: `env -u ZDOTDIR zsh -c 'print -r -- "$ZDOTDIR"'` should print
`/home/your-user/.config/zsh`.

## Make it yours

| File                                            | Change                                                                |
| ----------------------------------------------- | --------------------------------------------------------------------- |
| `env.zsh`                                       | Personal paths and app variables                                      |
| `.zshrc`                                        | History, named directories (`~hl`, `~res`), startup order             |
| `aliases/` and `binds.zsh`                      | Commands and keyboard shortcuts                                       |
| `prompt/p10k.zsh`                               | Prompt layout and colors                                              |
| `prompt/p10k-code.toml`                         | Project metadata modules                                              |
| `plugins/manual.zsh` and `plugins/deferred.zsh` | Active plugins                                                        |
| `apps/`                                         | Companion app configs to merge or link; FZF reads its config directly |

Plugin clones live in `~/.local/share/zsh/plugins`. The alternative Zinit loader
is inactive. Mise, opam, and pfetch integrations are enabled when available.

## Shortcuts and updates

| Key                            | Action                                |
| ------------------------------ | ------------------------------------- |
| `Esc` / `i`                    | Normal / insert mode                  |
| `Ctrl-F` / `Ctrl-R` / `Ctrl-O` | FZF files / history / directories     |
| `Ctrl-K` / `Ctrl-J`            | Previous / next line or history entry |
| `Ctrl-L`                       | Accept autosuggestion                 |
| `Ctrl-P`                       | Save current input with `push-line`   |

- `reload` — refresh aliases, functions, settings, and bindings.
- `promptreload` / `envreload` — refresh prompt / environment settings.
- `fullreload` — restart Zsh after plugin or integration changes.
- `zplugin-update` — update cloned plugins.
- `code-refresh` / `uv-direnv-rescan` — refresh project info / Python environment.

## Benchmark

Measured on login with [zsh-bench](https://github.com/romkatv/zsh-bench),
32 iterations:

| Metric            |     Result |
| ----------------- | ---------: |
| First prompt lag  |  66.036 ms |
| First command lag | 128.465 ms |
| Command lag       |   3.499 ms |
| Input lag         |   1.670 ms |
| Exit time         |  86.798 ms |

With zsh-bench cloned to `~/zsh-bench`, run:

```sh
ZSH_BENCH_RUN=1 "$HOME/zsh-bench/zsh-bench" --login yes --iters 32
```

The `zbench` alias runs this command. `ZSH_BENCH_RUN=1` binds `Ctrl-J` to
`accept-line` only in benchmark shells so zsh-bench can submit commands.
Normal shells keep `Ctrl-J` bound to `down-line-or-history`.

Inspired by [houssamouhra/zsh-config](https://github.com/houssamouhra/zsh-config).
[MIT license](LICENSE).
