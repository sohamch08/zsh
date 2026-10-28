# Initialize completions using the existing cache.
fpath=("$HOME/.local/share/zinit/completions" $fpath)
[[ -d "$HOME/.cache/zsh" ]] || mkdir -p "$HOME/.cache/zsh"
autoload -Uz compinit
compinit -d "$HOME/.cache/zsh/.zcompdump"

# Deja settings.
export DEJA_HIGHLIGHT_STYLE='fg=cyan'
export DEJA_ACCEPT_KEY=^L
export DEJA_CYCLE_KEY='^N'
export DEJA_CYCLE_FUZZY_KEY=
export DEJA_CYCLE_FUZZY_BACK_KEY=
export DEJA_TOGGLE_EMPTY_KEY=

# Load the already-installed plugins directly.
source "$HOME/.local/share/zinit/plugins/Giammarco-Ferranti---deja/deja.plugin.zsh"
source "$HOME/.local/share/zinit/plugins/zdharma-continuum---fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
source "$HOME/.local/share/zinit/plugins/romkatv---powerlevel10k/powerlevel10k.zsh-theme"
source "$ZDOTDIR/.p10k.zsh"
source "$HOME/.local/share/zinit/plugins/jeffreytse---zsh-vi-mode/zsh-vi-mode.plugin.zsh"
