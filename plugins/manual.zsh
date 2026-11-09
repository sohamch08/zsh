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
# Fast Compinit Load
# =========================================================

typeset -g ZSH_COMPDUMP="$HOME/.cache/zsh/.zcompdump"
zstyle ':plugin:ez-compinit' use-cache yes

_zplugin_load mattmc3 ez-compinit || return

# =========================================================
# Auto Completion
# =========================================================

_zplugin_load zsh-users zsh-completions || return

# =========================================================
# FZF-tab
# =========================================================

# Initialize cached completions before fzf-tab.
run-compinit
_comp_options+=(globdots)

# Searchable Tab completion.
_zplugin_load Aloxaf fzf-tab || return

zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"

# Preview directories when completing cd.
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --all --color=always -- "$realpath"'

# =========================================================
# FZF-git
# =========================================================

_zplugin_load junegunn fzf-git.sh fzf-git.sh || return

# =========================================================
# Autosuggestions
# =========================================================

typeset -g ZSH_AUTOSUGGEST_MANUAL_REBIND=1
typeset -g ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#7849cf'
typeset -g ZSH_AUTOSUGGEST_STRATEGY=(history)
typeset -g ZSH_AUTOSUGGEST_USE_ASYNC=1

_zplugin_load zsh-users zsh-autosuggestions zsh-autosuggestions.zsh || return

# =========================================================
# Prompt
# =========================================================

_zplugin_load romkatv powerlevel10k powerlevel10k.zsh-theme || return

# =========================================================
# Vi mode
# =========================================================

typeset -g ZVM_INIT_MODE=sourcing
typeset -g ZVM_CURSOR_STYLE_ENABLED=true

_zplugin_load jeffreytse zsh-vi-mode || return

# Native Zsh vi editing.
# bindkey -v

# Wait 10 ms to distinguish Escape from longer key sequences.
# KEYTIMEOUT=1

# =========================================================
# Colored Man Pages
# =========================================================

_zplugin_load houssamouhra colored-man-pages || return
