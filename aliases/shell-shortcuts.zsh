# Shell shortcuts.
alias sudo='sudo '
alias su='sudo su'
alias fuck='sudo !!'
alias c='clear'
alias cls='clear'

# Configuration editing and reloading.
alias zshedit='nvim "$ZDOTDIR/.zshrc"'
alias aliasedit='nvim "$ZDOTDIR/aliases"'
alias reload='source "$ZDOTDIR/.zshrc"'
alias promptreload='source "$ZDOTDIR/prompt/init.zsh"'
alias envreload='source "$ZDOTDIR/.zshenv"'
alias fullreload='exec zsh'

# Date and environment inspection.
alias now='date "+%Y-%m-%d %H:%M:%S"'
alias week='date "+%V"'
alias path='print -rl -- "${path[@]}"'

# Command availability and help.
has() {
  command -v "$1" >/dev/null 2>&1
}

alias bathelp='bat --plain --language=help'
alias man='batman'

help() {
  "$@" --help 2>&1 | bathelp
}
