# Refresh settings and aliases on reload.
source "$ZDOTDIR/integrations/fzf.zsh" || return
source "$ZDOTDIR/integrations/tifr-vpn.zsh" || return

# Install integration functions and hooks once per shell.
[[ -z ${_zsh_integrations_initialized-} ]] || return 0

# Zoxide.
if (($+commands[zoxide])); then
  eval "$(zoxide init --cmd cd zsh)"
fi

# FZF completion and widgets.
if (($+commands[fzf])); then
  if [[ -r /usr/share/fzf/shell/key-bindings.zsh &&
    -r /usr/share/fzf/shell/completion.zsh ]]; then
    source /usr/share/fzf/shell/key-bindings.zsh || return
    source /usr/share/fzf/shell/completion.zsh || return
  else
    eval "$(fzf --zsh)"
  fi
fi

# Mise.
if [[ -x "$HOME/.local/bin/mise" ]]; then
  eval "$("$HOME/.local/bin/mise" activate zsh)"
fi

# Direnv and your project environment hook.
source "$ZDOTDIR/integrations/direnv.zsh" || return

# Opam.
if [[ -r "$HOME/.opam/opam-init/init.zsh" ]]; then
  source "$HOME/.opam/opam-init/init.zsh" || return
fi

typeset -g _zsh_integrations_initialized=1
