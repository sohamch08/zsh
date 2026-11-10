# GPG terminal
if [[ -t 0 ]]; then
  export GPG_TTY=$TTY
fi

# Preserve colors on macOS.
if (( IS_MAC )); then
  unset NO_COLOR
fi

# Print intentional output before instant prompt.
if [[ -z ${_my_zsh_initialized-} ]]; then
  if (( IS_MAC )); then
    if (( $+commands[fastfetch] )); then
      command fastfetch
    fi
  elif [[ -n ${SSH_CONNECTION-} ]]; then
    source "$ZDOTDIR/integrations/pfetch.zsh" || return
    pfetch-banner
  fi
fi

# Apply the initial project environment and show instant prompt.
if [[ -z ${_my_zsh_initialized-} ]]; then
  if (( $+commands[direnv] )); then
    emulate zsh -c "$(direnv export zsh)"
  fi

  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
fi

# History
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

# Shell behaviour
setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT
setopt CORRECT

# Refresh aliases and functions on reload.
source "$ZDOTDIR/aliases/init.zsh" || return
source "$ZDOTDIR/functions.zsh" || return

# Named directories
hash -d hl="$HOME/projects/HyprLife"
hash -d res="$HOME/projects/Research"

# Initialize plugins once per shell.
if [[ -z ${_zsh_plugins_initialized-} ]]; then
  source "$ZDOTDIR/plugins/manual.zsh" || return
  typeset -g _zsh_plugins_initialized=1
fi

# Shared integrations
source "$ZDOTDIR/integrations/init.zsh" || return

# Mac integrations
if (( IS_MAC )); then
  source "$ZDOTDIR/integrations/neomutt.zsh" || return
  unset GIT_PAGER
fi

# Initialize the prompt once per shell.
if [[ -z ${_my_zsh_initialized-} ]]; then
  source "$ZDOTDIR/prompt/init.zsh" || return
fi

# Use zoxide when available.
cd() {
  if (( $+functions[__zoxide_z] )); then
    __zoxide_z "$@"
  else
    builtin cd -- "$@"
  fi
}

# Refresh bindings on reload.
source "$ZDOTDIR/binds.zsh" || return

# Defer optional plugins until the shell is waiting for input.
if [[ -z ${_my_zsh_initialized-} ]]; then
  zsh-defer -12 source "$ZDOTDIR/plugins/deferred.zsh"
fi

# Keep unexported so child shells initialize independently.
typeset -g _my_zsh_initialized=1