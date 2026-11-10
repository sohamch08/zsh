# ---------- GPG ----------
if [[ -t 0 ]]; then
  export GPG_TTY=$TTY
fi

# Print the startup banner before Powerlevel10k redirects console output.
if [[ -n ${SSH_CONNECTION-} && -z ${_my_zsh_initialized-} ]]; then
  source "$ZDOTDIR/integrations/pfetch.zsh" || return
  pfetch-banner
fi

# =========================================================
# Powerlevel10k instant prompt — keep below intentional console output
# =========================================================

if [[ -z ${_my_zsh_initialized-} ]]; then
  # Apply the initial project environment before displaying instant prompt.
  if (($+commands[direnv])); then
    emulate zsh -c "$(direnv export zsh)"
  fi

  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
fi

# =========================================================
# History
# =========================================================

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

HISTSIZE=1000000
SAVEHIST=1000000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY

# =========================================================
# Shell behaviour
# =========================================================

setopt AUTOCD            # Enter directories by typing their path
setopt NOBEEP            # Disable terminal bell
setopt NUMERIC_GLOB_SORT # Sort file2 before file10
setopt CORRECT           # Suggest corrections for command names

# =========================================================
# Aliases, functions, and bookmarks: refreshed on reload
# =========================================================

source "$ZDOTDIR/aliases/init.zsh" || return
source "$ZDOTDIR/functions.zsh" || return
source "$ZDOTDIR/bookmarks.zsh" || return

# =========================================================
# Plugins: initialized once per shell
# =========================================================

if [[ -z ${_zsh_plugins_initialized-} ]]; then

  source "$ZDOTDIR/plugins/manual.zsh" || return

  typeset -g _zsh_plugins_initialized=1
fi

# =========================================================
# Integration settings and once-per-shell hooks
# =========================================================

source "$ZDOTDIR/integrations/init.zsh" || return

# =========================================================
# Prompt: refreshed separately with promptreload
# =========================================================

if [[ -z ${_my_zsh_initialized-} ]]; then
  source "$ZDOTDIR/prompt/init.zsh" || return
fi

# =========================================================
# Bookmark-aware directory navigation
# =========================================================

cd() {
  if (($# == 1)) && [[ -n ${CD_BOOKMARKS[$1]-} ]]; then
    builtin cd -- "${CD_BOOKMARKS[$1]}"
  elif (($+functions[__zoxide_z])); then
    __zoxide_z "$@"
  else
    builtin cd -- "$@"
  fi
}

# =========================================================
# Custom bindings: refreshed on reload
# =========================================================

source "$ZDOTDIR/binds.zsh" || return

# Load optional plugins once the shell is waiting for input.
if [[ -z ${_my_zsh_initialized-} ]]; then
  zsh-defer -12 source "$ZDOTDIR/plugins/deferred.zsh"
fi

# Keep unexported so child shells initialize independently.
typeset -g _my_zsh_initialized=1
