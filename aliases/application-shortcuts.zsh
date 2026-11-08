# Application shortcuts.
alias lg='lazygit'
alias e='nvim'
alias m='neomutt'
alias o='xdg-open'
alias y='yazi'
alias nvimb="nvim -c 'set backup backupdir=. backupext=~ backupskip='"
alias cmus='tmux new-session -A -D -s cmus /usr/bin/cmus'

# KeePassXC command-line interface.
kpxc() {
  flatpak run --command=keepassxc-cli org.keepassxc.KeePassXC "$@"
}

# Matrix rain.
alias neo='neo -S 14 -f 60 -d 0.8 -c green --lingerms 1,1 --rippct 0 --shortpct 0'
alias neowake='neo -m "WAKE UP, SOHAM"'
alias neorabbit='neo -m "FOLLOW THE WHITE RABBIT"'
alias neomind='neo -m "FREE YOUR MIND"'
alias neoredpill='neo -m "THIS TIME, CHOOSE THE RED PILL"'

# C compilation with diagnostic flags.
cstudy() {
  command gcc \
    -std=c17 -g -O2 \
    -Wall -Wextra -Wpedantic \
    -Wformat=2 -Wshadow -Wwrite-strings \
    -Wstrict-prototypes -Wold-style-definition \
    -Wredundant-decls -Wnested-externs \
    -Wmissing-include-dirs \
    -Wjump-misses-init -Wlogical-op \
    "$@"
}

# TeX Live configuration formatters.
alias tlconf='tlmgr conf | awk -v cols="$(tput cols)" -f "$ZDOTDIR/tools/tlconf/tlconf.awk"'
alias tlconf-simple='tlmgr conf | awk -v cols="${COLUMNS:-100}" -f "$ZDOTDIR/tools/tlconf/tlconf-simple.awk"'
