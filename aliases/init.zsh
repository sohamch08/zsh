source "$ZDOTDIR/aliases/shell.zsh" || return
source "$ZDOTDIR/aliases/files.zsh" || return

if (( IS_LINUX )); then
  source "$ZDOTDIR/aliases/packages.zsh" || return
  source "$ZDOTDIR/aliases/system.zsh" || return
fi

source "$ZDOTDIR/aliases/applications.zsh" || return
source "$ZDOTDIR/aliases/rcaliases-pretty.zsh" || return

if (( IS_MAC )); then
  source "$ZDOTDIR/platforms/macos/aliases.zsh" || return
fi