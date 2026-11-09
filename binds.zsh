# =========================================================
# Key Bindings
# =========================================================

# bindkey '^K' up-line-or-history
# bindkey '^J' down-line-or-history

_zsh_fzf_bindings() {
  local keymap
  for keymap in emacs viins vicmd; do
    bindkey -M "$keymap" '^F' fzf-file-widget
    bindkey -M "$keymap" '^R' fzf-history-widget
    bindkey -M "$keymap" '^O' fzf-cd-widget
    bindkey -M "$keymap" '\ec' fzf-cd-widget
    bindkey -M "$keymap" '^K' up-line-or-history
    bindkey -M "$keymap" '^J' down-line-or-history
    bindkey -M "$keymap" '^P' push-line
    bindkey -M "$keymap" '^L' autosuggest-accept
  done
}

# zsh-vi-mode initializes insert and normal bindings at different times.
((${zvm_after_init_commands[(Ie)_zsh_fzf_bindings]})) ||
  zvm_after_init_commands+=(_zsh_fzf_bindings)
((${zvm_after_lazy_keybindings_commands[(Ie)_zsh_fzf_bindings]})) ||
  zvm_after_lazy_keybindings_commands+=(_zsh_fzf_bindings)
_zsh_fzf_bindings

# Rebind autosuggestions after vi-mode changes editor widgets.
((${zvm_after_init_commands[(Ie)_zsh_autosuggest_bind_widgets]})) ||
  zvm_after_init_commands+=(_zsh_autosuggest_bind_widgets)

((${zvm_after_lazy_keybindings_commands[(Ie)_zsh_autosuggest_bind_widgets]})) ||
  zvm_after_lazy_keybindings_commands+=(_zsh_autosuggest_bind_widgets)
