fastfetch

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Quoted "~" is not expanded by zsh, so use $HOME/XDG vars instead
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
setopt CORRECT

# =========================================================
# Shell behaviour
# =========================================================

setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT  # sort file10 after file9, not after file1



# =========================================================
# Modular Config Files
# =========================================================
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/rcaliases.zsh"
source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/binds.zsh"


# =========================================================
# Initialize apps
# =========================================================

eval "$(zoxide init --cmd cd zsh)"
eval "$(fzf --zsh)"
# eval "$(atuin init zsh)"

. "$HOME/.local/share/../bin/env"

eval "$(~/.local/bin/mise activate zsh)"
