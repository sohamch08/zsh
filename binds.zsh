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
    bindkey -M "$keymap" '^K' up-line-or-history
    bindkey -M "$keymap" '^J' down-line-or-history
    bindkey -M "$keymap" '^P' push-line
    bindkey -M "$keymap" '^L' autosuggest-accept
    bindkey -M "$keymap" -r '\ec'
    bindkey -M "$keymap" -r '^G'
  done
}

# Vi-mode installs normal-mode bindings on the first Escape press.
_zsh_vi_lazy_bindings() {
  _zsh_fzf_bindings
  if (( $+functions[_zsh_autosuggest_bind_widgets] )); then
    _zsh_autosuggest_bind_widgets
  fi
}

# Register before the deferred vi-mode plugin initializes; avoid duplicates on reload.
typeset -ga zvm_after_init_commands zvm_after_lazy_keybindings_commands
((${zvm_after_init_commands[(Ie)_zsh_fzf_bindings]})) ||
  zvm_after_init_commands+=(_zsh_fzf_bindings)
((${zvm_after_lazy_keybindings_commands[(Ie)_zsh_vi_lazy_bindings]})) ||
  zvm_after_lazy_keybindings_commands+=(_zsh_vi_lazy_bindings)
_zsh_fzf_bindings
