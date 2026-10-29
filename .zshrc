# =========================================================
# Powerlevel10k instant prompt — keep at the top
# =========================================================

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
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
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS


# =========================================================
# Shell behaviour
# =========================================================

setopt AUTOCD             # Enter directories by typing their path
setopt NOBEEP             # Disable terminal bell
setopt NUMERIC_GLOB_SORT  # Sort file2 before file10
setopt CORRECT            # Suggest corrections for command names


# =========================================================
# Aliases, functions and settings — refreshed on reload
# =========================================================

source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/bookmarks.zsh"
source "$ZDOTDIR/rcaliases.zsh"
source "$ZDOTDIR/fzf.zsh"
source "$ZDOTDIR/tifr-vpn.zsh"


# =========================================================
# Initialization — runs once per shell
# =========================================================

if [[ -z ${_my_zsh_initialized-} ]]; then

  # -------------------------------------------------------
  # Plugins and prompt
  # plugins.zsh also loads .p10k.zsh on initial startup.
  # -------------------------------------------------------

  source "$ZDOTDIR/plugins-woZinit.zsh"

  # -------------------------------------------------------
  # Zoxide — directory navigation
  # -------------------------------------------------------

  eval "$(zoxide init --cmd cd zsh)"

  # -------------------------------------------------------
  # Fzf — completion and default keybindings
  # -------------------------------------------------------

  eval "$(fzf --zsh)"

  # -------------------------------------------------------
  # Local binaries
  # -------------------------------------------------------

  source "$HOME/.local/bin/env"

  # -------------------------------------------------------
  # Mise — development tool environments
  # -------------------------------------------------------

  eval "$(~/.local/bin/mise activate zsh)"

  # -------------------------------------------------------
  # Direnv — project environment activation
  # -------------------------------------------------------

  source "$ZDOTDIR/autoenv.zsh"

  # Keep this variable unexported so new shells initialize.
  typeset -g _my_zsh_initialized=1
#
# else
#
#   # -------------------------------------------------------
#   # Reload prompt settings without reinitializing plugins
#   # -------------------------------------------------------
#
#   source "$ZDOTDIR/.p10k.zsh"
#
fi


# =========================================================
# Custom keybindings — refreshed on reload
# =========================================================

source "$ZDOTDIR/binds.zsh"
