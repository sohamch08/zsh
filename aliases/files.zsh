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
