# ----- Application shortcuts -----
alias e='nvim'
alias j='just'
alias nvimb="nvim -c 'set backup backupdir=. backupext=~ backupskip='"
alias lg='lazygit'
alias m='neomutt'
alias y='yazi'
alias o='xdg-open'
alias cmus='tmux new-session -A -D -s cmus /usr/bin/cmus'

# ----- Matrix effects -----
alias neo='neo -S 14 -f 60 -d 0.8 -c green --lingerms 1,1 --rippct 0 --shortpct 0'
alias neowake='neo -m "WAKE UP, SOHAM"'
alias neorabbit='neo -m "FOLLOW THE WHITE RABBIT"'
alias neomind='neo -m "FREE YOUR MIND"'
alias neoredpill='neo -m "THIS TIME, CHOOSE THE RED PILL"'

# ----- TeX Live -----
alias tlconf='tlmgr conf | awk -v cols="$(tput cols)" -f "$ZDOTDIR/tools/tlconf/tlconf.awk"'
alias tlconf-simple='tlmgr conf | awk -v cols="${COLUMNS:-100}" -f "$ZDOTDIR/tools/tlconf/tlconf-simple.awk"'

# ----- Tmux -----
alias tma="tmux attach-session"
alias tmls="tmux ls"
alias tmk="tmux kill-session"
