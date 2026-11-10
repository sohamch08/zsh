# ----- File viewing -----
alias cat='bat'
alias b='bat'

# ----- Directory listings -----
alias eza='eza --icons=always'
alias ls='eza -ag --color=always --group-directories-first --sort=type'
alias sl='ls'
alias ll='eza -alghH --color=always --group-directories-first --sort=type --git'
alias l='ll'
alias la='ll'

# ----- Tree views -----
alias lt='eza -aT --color=always --group-directories-first --ignore-glob="$(paste -sd "|" ~/.config/eza/ignore)"'
alias lt2='eza -aT --level=2 --color=always --group-directories-first --ignore-glob="$(paste -sd "|" ~/.config/eza/ignore)"'

# ----- Sorted listings -----
alias lS='eza -alghH --color=always --group-directories-first --sort=size'
alias lm='eza -alghH --color=always --group-directories-first --sort=modified'

# ----- File operations -----
alias del='shred -uzn3'
alias rm='rm -Iv'
alias mv='mv -iv'

# ----- Disk usage: visual exploration -----
alias ds='dust'
alias ds1='dust -d 1'
alias ds2='dust -d 2'
alias dsfiles='dust -F -n 20'

# ----- File and directory sizes -----
alias dus='du -sh'     # One total per supplied path
alias du1='du -h -d 1' # Directory totals, one level deep
alias du2='du -h -d 2' # Directory totals, two levels deep

# ----- Filesystem capacity -----
alias dfh='df -hT' # Readable sizes and filesystem types
alias dfi='df -hi' # Inode usage
