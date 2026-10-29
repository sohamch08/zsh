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
mkdir -p "$HOME/.cache/zsh"
ZINIT[ZCOMPDUMP_PATH]="$HOME/.cache/zsh/.zcompdump"
autoload -Uz compinit
compinit -d "${ZINIT[ZCOMPDUMP_PATH]}"

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# =========================================================
# Plugins
# =========================================================


###########################################################
#### DEJA #################################################
###########################################################

# Deja overrides
export DEJA_HIGHLIGHT_STYLE='fg=cyan'
export DEJA_ACCEPT_KEY=^L
export DEJA_CYCLE_KEY='^N'
export DEJA_CYCLE_FUZZY_KEY=
export DEJA_CYCLE_FUZZY_BACK_KEY=
export DEJA_TOGGLE_EMPTY_KEY=

# Initialize Deja once per shell. Reloading it after Powerlevel10k can
# make their saved line-editor hooks call each other recursively.
if (( ! ${+functions[_deja_fetch]} )); then
    zinit ice depth=1 pick"deja.plugin.zsh"
    zinit light Giammarco-Ferranti/deja
fi



###########################################################
#### Syntax Highlight #####################################
###########################################################

zinit light zdharma-continuum/fast-syntax-highlighting


###########################################################
#### Powerlevel 10k Prompt ################################
###########################################################

zinit ice depth=1; zinit light romkatv/powerlevel10k
[[ ! -f ~/.zsh/.p10k.zsh ]] || source ~/.zsh/.p10k.zsh


###########################################################
#### ZSH VI Mode ##########################################
###########################################################

zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode
