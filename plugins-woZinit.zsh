# =========================================================
# Plugin directory and loader
# =========================================================

ZPLUGINDIR="$HOME/.local/share/zsh/plugins"

# Usage: _zplugin_load owner repo [entry-file]
_zplugin_load() {
  local owner="$1" repo="$2"
  local entry="${3:-${2}.plugin.zsh}"
  local file="${ZPLUGINDIR}/${owner}---${repo}/${entry}"

  if [[ ! -r "$file" ]]; then
    print -ru2 -- "Missing plugin: $file"
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

[[ ! -r "${ZDOTDIR:-$HOME/.config/zsh}/.p10k.zsh" ]] ||
  source "${ZDOTDIR:-$HOME/.config/zsh}/.p10k.zsh"

# =========================================================
# Vi mode
# =========================================================

_zplugin_load jeffreytse zsh-vi-mode
