# =========================================================
# Plugin directory and loader
# =========================================================

ZPLUGINDIR="$HOME/.local/share/zsh/plugins"

# Usage: _zplugin_load owner repo [entry-file]
_zplugin_load() {
  local owner="$1" repo="$2"
  local entry="${3:-${2}.plugin.zsh}"
  local plugin_dir="${ZPLUGINDIR}/${owner}---${repo}"
  local file="${plugin_dir}/${entry}"

  if [[ ! -d "$plugin_dir" ]]; then
    command mkdir -p -- "$ZPLUGINDIR" || return 1
    print -ru2 -- "Installing ${owner}/${repo}..."

    command git clone --depth=1 -- \
      "https://github.com/${owner}/${repo}.git" "$plugin_dir" || {
        print -ru2 -- "ERROR: failed to install ${owner}/${repo}"
        return 1
      }
  fi

  if [[ ! -r "$file" ]]; then
    print -ru2 -- "Missing plugin entry: $file"
    return 1
  fi

  source "$file"
}

# Runs only when explicitly called.
zplugin-update() {
  local dir
  local -i failed=0

  for dir in "${ZPLUGINDIR}"/*(N/); do
    [[ -d "$dir/.git" ]] || continue
    print -r -- "Updating ${dir:t}..."
    git -C "$dir" pull --ff-only || failed=1
  done

  return "$failed"
}

# =========================================================
# Completions
# =========================================================

# Preserve completion for fast-theme without Zinit's symlinks.
fpath=(
  "$ZPLUGINDIR/zdharma-continuum---fast-syntax-highlighting"
  $fpath
)

[[ -d "$HOME/.cache/zsh" ]] || mkdir -p "$HOME/.cache/zsh"
autoload -Uz compinit
compinit -d "$HOME/.cache/zsh/.zcompdump"

# =========================================================
# Deja
# =========================================================

export DEJA_HIGHLIGHT_STYLE='fg=cyan'
export DEJA_ACCEPT_KEY='^L'
export DEJA_CYCLE_KEY='^N'
export DEJA_CYCLE_FUZZY_KEY=
export DEJA_CYCLE_FUZZY_BACK_KEY=
export DEJA_TOGGLE_EMPTY_KEY=

if (( ! ${+functions[_deja_fetch]} )); then
  _zplugin_load Giammarco-Ferranti deja
fi

# =========================================================
# Syntax highlighting
# =========================================================

_zplugin_load zdharma-continuum fast-syntax-highlighting

# =========================================================
# Prompt
# =========================================================

_zplugin_load romkatv powerlevel10k powerlevel10k.zsh-theme

[[ ! -r "${ZDIR:-$HOME/.zsh}/.p10k.zsh" ]] ||
  source "${ZDIR:-$HOME/.zsh}/.p10k.zsh"

# =========================================================
# Vi mode
# =========================================================

# _zplugin_load jeffreytse zsh-vi-mode

# Native Zsh vi editing.
bindkey -v

# Wait 10 ms to distinguish Escape from longer key sequences.
KEYTIMEOUT=1
