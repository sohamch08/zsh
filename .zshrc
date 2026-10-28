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
# Zinit Plugin Manager
# =========================================================

if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# Store the completion cache outside the config directory.
ZINIT[ZCOMPDUMP_PATH]="$HOME/.cache/zsh/.zcompdump"
autoload -Uz compinit
compinit -d "${ZINIT[ZCOMPDUMP_PATH]}"

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

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


