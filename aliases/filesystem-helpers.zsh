# File contents.
alias cat='bat'
alias b='bat'

# Directory listings.
alias eza='eza --icons=always'
alias ls='eza -ag --color=always --group-directories-first --sort=type'
alias sl='ls'
alias ll='eza -alghH --color=always --group-directories-first --sort=type --git'
alias l='ll'
alias la='ll'
alias lt='eza -aT --color=always --group-directories-first --ignore-glob="$(paste -sd "|" ~/.config/eza/ignore)"'
alias lt2='eza -aT --level=2 --color=always --group-directories-first --ignore-glob="$(paste -sd "|" ~/.config/eza/ignore)"'
alias lS='eza -alghH --color=always --group-directories-first --sort=size'
alias lm='eza -alghH --color=always --group-directories-first --sort=modified'

# File operations.
alias del='shred -uzn3'
alias rm='rm -Iv'

# Rename files in the current directory: rename_series 5cmPerSec
rename_series() {
  if (($# != 1)); then
    print -u2 'Usage: rename_series PREFIX'
    return 1
  fi

  local file ext new_name
  local -i i=1

  for file in *.*(N.); do
    ext="${file##*.}"
    printf -v new_name '%s%02d.%s' "$1" "$i" "$ext"
    if [[ "$file" != "$new_name" ]]; then
      mv -i -- "$file" "$new_name" || return
    fi
    ((i++))
  done
}

alias mv='mv -iv'

# Archive extraction.
extract() {
  [[ -f "$1" ]] || {
    echo "File not found"
    return 1
  }

  case "$1" in
  *.tar.gz | *.tgz) tar -xzf "$1" ;;
  *.tar.bz2) tar -xjf "$1" ;;
  *.tar.xz) tar -xJf "$1" ;;
  *.7z) 7z x "$1" ;;
  *.zip) unzip "$1" ;;
  *.gz) gunzip "$1" ;;
  *.bz2) bunzip2 "$1" ;;
  *) echo "Unsupported format" ;;
  esac
}
