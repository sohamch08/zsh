# Quoted "~" is not expanded by zsh, so use $HOME/XDG vars instead
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt CORRECT

# =========================================================
# Shell behaviour
# =========================================================

setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT  # sort file10 after file9, not after file1


# =========================================================
# Smart directory navigation & Yazi
# =========================================================


# Initialize zoxide
eval "$(zoxide init --cmd cd zsh)"
eval "$(fzf --zsh)"
# eval "$(atuin init zsh)"

fastfetch

. "$HOME/.local/share/../bin/env"

eval "$(~/.local/bin/mise activate zsh)"
