# ----- Privilege shortcuts -----
alias sudo='sudo '
alias su='sudo su'
alias fuck='sudo !!'

# ----- Clear Commands -----
alias c='clear'
alias cls='clear'

# ----- Configuration editing -----
alias zshedit='nvim "$ZDOTDIR/.zshrc"'
alias aliasedit='nvim "$ZDOTDIR/aliases"'

# ----- Configuration reloading -----
alias reload='source "$ZDOTDIR/.zshrc"'
alias promptreload='source "$ZDOTDIR/prompt/init.zsh"'
alias envreload='source "$ZDOTDIR/.zshenv"'
alias fullreload='exec zsh'

# ----- Date and environment -----
alias now='date "+%Y-%m-%d %H:%M:%S"'
alias week='date "+%V"'
alias path='print -rl -- "${path[@]}"'

# ----- Manuals and help -----
alias bathelp='bat --plain --language=help'
alias man='batman'

# ----- Shell benchmarks -----
alias zbench='"$HOME/zsh-bench/zsh-bench"'
alias zbench-login='zbench --login yes'
alias zbench-interactive='zbench --login no'
alias zbench8='zbench --iters 8'
