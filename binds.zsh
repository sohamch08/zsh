# =========================================================
# Key Bindings
# =========================================================

# Use Zsh's built-in vi editing mode; KEYTIMEOUT is in hundredths of a second.
bindkey -v
KEYTIMEOUT=10

# DECSCUSR: steady block in normal mode, steady bar in insert mode.
_zsh_vi_cursor() {
  case $KEYMAP in
    vicmd) print -rn -- $'\e[2 q' ;;
    *)     print -rn -- $'\e[6 q' ;;
  esac
}

# Restore the terminal's default cursor before running a command.
_zsh_reset_cursor() {
  print -rn -- $'\e[0 q'
}

autoload -Uz add-zle-hook-widget
add-zle-hook-widget line-init _zsh_vi_cursor
add-zle-hook-widget keymap-select _zsh_vi_cursor
add-zle-hook-widget line-finish _zsh_reset_cursor

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
    bindkey -M viins '^?' backward-delete-char
    bindkey -M viins '^H' backward-delete-char
    bindkey -M "$keymap" -r '\ec'
    bindkey -M "$keymap" -r '^G'
  done
}

_zsh_fzf_bindings
