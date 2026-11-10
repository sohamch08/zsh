alias glow="$HOME/.local/bin/glow"
alias mdread="$HOME/.local/bin/mdread"
alias mdfried="$HOME/.local/bin/mdfried"

# Homebrew Aliases
alias i='brew install'               # i wget
alias u='brew update && brew upgrade'
alias brm='brew uninstall'           # brm wget
alias brs='brew search'               # bs python
alias brinfo='brew info'              # binfo ffmpeg
alias brls='brew list --versions'      # Installed packages and versions
alias brout='brew outdated'           # Available upgrades
alias brefresh='brew update'         # Refresh package metadata
alias brdeps='brew deps --tree'       # bdeps ffmpeg
alias bwhy='brew uses --installed'   # bwhy openssl@3
alias brdoctor='brew doctor'          # Diagnose setup problems
alias brclean='brew autoremove && brew cleanup'

# ─── Extra Aliases  ──────────────────────────────────────────────────────
# Enable Lazygit colors even when the parent process disables color output.
alias lazygit='env -u NO_COLOR TERM=xterm-256color COLORTERM=truecolor lazygit'

alias o='open'
alias cmus='tmux new-session -A -D -s cmus cmus'
unalias man 2>/dev/null