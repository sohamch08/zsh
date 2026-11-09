# Initialize this group only once per shell.
[[ -z ${_zsh_deferred_plugins_initialized-} ]] || return 0

# =========================================================
# FZF-tab
# =========================================================

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
# Vi mode
# =========================================================

typeset -g ZVM_INIT_MODE=sourcing
typeset -g ZVM_CURSOR_STYLE_ENABLED=true
typeset -g ZVM_LAZY_KEYBINDINGS=true

_zplugin_load jeffreytse zsh-vi-mode || return

# Bind suggestions once, after vi-mode has installed its editor widgets.
_zsh_autosuggest_start

# =========================================================
# Colored Man Pages
# =========================================================

_zplugin_load houssamouhra colored-man-pages || return

# =========================================================
# Syntax Highlighting
# =========================================================

eval "$("$HOME/.cargo/bin/zsh-patina" activate)"

typeset -g _zsh_deferred_plugins_initialized=1
