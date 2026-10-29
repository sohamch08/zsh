# =========================================================
# Aliases
# =========================================================

alias sudo="sudo "
alias cat="bat"
alias reload="source $ZDOTDIR/.zshrc"
alias zshedit="nvim $ZDOTDIR/.zshrc"
alias aliasedit="nvim $ZDOTDIR/aliases.zsh"
alias nvimb="nvim -c 'set backup backupdir=. backupext=~ backupskip='"
alias promptreload='source "$ZDOTDIR/.p10k.zsh"'
alias fullreload='source "$ZDOTDIR/.zshrc" && source "$ZDOTDIR/.p10k.zsh"'

# ─── EZA Aliases  ──────────────────────────────────────────────────────
alias eza='eza --icons=always'
alias ls='eza -ag --color=always --group-directories-first --sort=type'
alias sl='ls'
alias ll='eza -alghH --color=always --group-directories-first --sort=type --git'
alias lt='eza -aT --color=always --group-directories-first'
alias lt2='eza -aT --level=2 --color=always --group-directories-first'
alias lS='eza -alghH --color=always --group-directories-first --sort=size'
alias lm='eza -alghH --color=always --group-directories-first --sort=modified'


# ─── DNF Aliases  ──────────────────────────────────────────────────────
alias i="sudo dnf install -y"
alias u="sudo dnf upgrade --refresh -y"
alias autoremove="sudo dnf autoremove -y"
alias lock="sudo dnf versionlock add"
alias unlock="sudo dnf versionlock delete"
alias uninstall="sudo dnf remove -y"
alias locks="dnf versionlock list"


# ─── Extra Aliases  ──────────────────────────────────────────────────────
alias lg="lazygit"
alias b="bat"
alias c="clear"
alias e="nvim"
alias l="ll"
alias la="lla"
alias m="neomutt"
alias o="xdg-open"
alias su="sudo su"
alias y="yazi"
alias del='shred -uzn3'
alias rm="rm -Iv"
alias cls="clear"

# ─── Extra Functions  ───────────────────────────────────────────────────
cd() {
  if (( $# == 1 )) && [[ -n ${CD_BOOKMARKS[$1]-} ]]; then
    builtin cd -- "${CD_BOOKMARKS[$1]}"
  else
    __zoxide_z "$@"
  fi
}
# Rename files in the current directory: rename_series 5cmPerSec
rename_series() {
  if (( $# != 1 )); then
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
    (( i++ ))
  done
}

extract () {
  [[ -f "$1" ]] || { echo "File not found"; return 1; }

  case "$1" in
    *.tar.gz|*.tgz) tar -xzf "$1" ;;
    *.tar.bz2)      tar -xjf "$1" ;;
    *.tar.xz)       tar -xJf "$1" ;;
    *.zip)          unzip "$1" ;;
    *.gz)           gunzip "$1" ;;
    *.bz2)          bunzip2 "$1" ;;
    *) echo "Unsupported format" ;;
  esac
}
alias fuck="sudo !!"

flatpak() {
    if [[ "$1" == "list" && $# -eq 1 ]]; then
        command flatpak list --runtime --columns=name,application,branch,size
    else
        command flatpak "$@"
    fi
}

has() {
    command -v "$1" >/dev/null 2>&1
}
alias lsbc="lsblk | bat -l conf -p"
alias freee="free -h | bat -l conf -p"
alias bathelp='bat --plain --language=help'
help() {
    "$@" --help 2>&1 | bathelp
}
kpxc() {
  flatpak run --command=keepassxc-cli org.keepassxc.KeePassXC "$@"
}
alias man="batman"
alias sensors="sensors | bat -l cpuinfo -p"
alias mv="mv -iv"
alias now='date "+%Y-%m-%d %H:%M:%S"'
alias week='date "+%V"'
alias path='print -rl -- "${path[@]}"'
alias cpuinfo='lscpu | bat -p -l cpuinfo'
alias blockdevices='lsblk -f | bat -p -l fstab --wrap=never'
alias pci='lspci | bat -p -l properties'
alias usb='lsusb | bat -p -l fstab'
alias mounts='findmnt | bat -p -l fstab --wrap=never'
alias gpg-fingerprint="gpg --with-colons --fingerprint | awk -F: '\$1==\"pub\"{p=1} \$1==\"fpr\" && p{print \$10; p=0}'"

