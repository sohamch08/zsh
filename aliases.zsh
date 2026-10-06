alias cat="bat"
alias reload="source $ZDOTDIR/.zshrc"
alias zshedit="nvim $ZDOTDIR/.zshrc"
alias aliasedit="nvim $ZDOTDIR/aliases.zsh"

# eza aliases
alias eza='eza --icons=always'
alias ls='eza -ag --color=always --group-directories-first --sort=type'
alias sl='ls'
alias ll='eza -alghH --color=always --group-directories-first --sort=type --git'
alias lt='eza -aT --color=always --group-directories-first'
alias lt2='eza -aT --level=2 --color=always --group-directories-first'
alias lS='eza -alghH --color=always --group-directories-first --sort=size'
alias lm='eza -alghH --color=always --group-directories-first --sort=modified'


# ─── Extra FUNCTIONS  ──────────────────────────────────────────────────────
alias b="bat"
alias c="clear"
alias e="nvim"
alias l="ll"
alias la="lla"
alias m="neomutt"
alias i="sudo dnf install -y"
alias u="sudo dnf upgrade --refresh -y"
alias autoremove="sudo dnf autoremove -y"
alias lock="sudo dnf versionlock add"
alias unlock="sudo dnf versionlock delete"
alias uninstall="sudo dnf remove -y"
alias locks="dnf versionlock list"
alias o="xdg-open"
alias su="sudo su"
alias reboot='sudo /sbin/reboot'
alias poweroff='sudo /sbin/poweroff'
alias ve='python3 -m venv ./venv'
alias va='source ./venv/bin/activate'
alias y="yazi"
alias del='shred -uzn3'
alias rm="rm -Iv"
alias rmdir='rm -rf'
mkcd () {
  mkdir -p -- "$1" && cd -- "$1"
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
cl() {
    last_dir="$(/bin/ls -Frt | grep '/$' | tail -n1)"
    if [ -d "$last_dir" ]; then
            cd "$last_dir"
    fi
}
rd(){
    pwd > "$HOME/.lastdir_$1"
}

crd(){
    lastdir="$(cat "$HOME/.lastdir_$1")">/dev/null 2>&1
    if [ -d "$lastdir" ]; then
            cd "$lastdir"
    else
            echo "no existing directory stored in buffer $1">&2
    fi
}
alias copy='xclip -selection clipboard'
fcd() { zle fzf-cd-widget 2>/dev/null || { local d; d=$(fd --type d --hidden | fzf +m --preview 'tree -C {} | head -200') && cd "$d"; } }
alias env="list_env"
alias glolf="git log --oneline --all --color=always | fzf -m --no-sort --ansi --preview='git show --color=always {1}' | awk '{print $1}'"

flatpak() {
    if [[ "$1" == "list" && $# -eq 1 ]]; then
        command flatpak list --runtime --columns=name,application,branch,size
    else
        command flatpak "$@"
    fi
}

function md() {
  pandoc $1 > /tmp/$1.html
  xdg-open /tmp/$1.html
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
alias man="batman"
alias sensors="sensors | bat -l cpuinfo -p"
alias mv="mv -iv"
alias now='date "+%Y-%m-%d %H:%M:%S"'
alias week='date "+%V"'
alias path='print -rl -- "${path[@]}"'
case "$(uname -s)" in
    Darwin)
        export AWESOME_ALIAS_OS="macos"
        ;;
    Linux)
        export AWESOME_ALIAS_OS="linux"
        ;;
    *)
        export AWESOME_ALIAS_OS="other"
        ;;
esac
_sc() {
    emulate -L zsh
    setopt pipefail

    command systemctl --no-pager "$@" |
        perl -pe '
            BEGIN { %c = (active=>36, running=>32, exited=>31, failed=>31) }
            s/\b(active|running|exited|failed)\b/\e[$c{$1}m$1\e[0m/g;
            s/^(\s*(?:\S+\s+)?)(\S+\.service)(?=\s)/$1\e[34m$2\e[0m/;
        ' |
        bat -pp -l txt --strip-ansi=never
}

_jc() {
    emulate -L zsh
    setopt pipefail

    SYSTEMD_COLORS=0 SYSTEMD_URLIFY=0 \
        command journalctl --no-pager --output=short "$@" |
        bat -pp -l syslog --strip-ansi=always
}

if [ "$AWESOME_ALIAS_OS" = "linux" ]; then
    alias services='systemctl --no-pager --full --type=service | bat -p -l properties --wrap=never'
    alias sc='_sc'
    alias scu='_sc --user'
    alias jc='_jc'
    alias jcf='_jc --follow'
    alias jcb='_jc --boot'
    alias jcxe='_jc --catalog --lines=1000'
    alias cpuinfo='lscpu | bat -p -l cpuinfo'
    alias blockdevices='lsblk -f | bat -p -l fstab --wrap=never'
    alias pci='lspci | bat -p -l properties'
    alias usb='lsusb | bat -p -l fstab'
    alias mounts='findmnt | bat -p -l fstab --wrap=never'
    alias journalerrors='journalctl --no-pager -p err -b | bat -p -l syslog --wrap=never'
    alias failedservices='systemctl --no-pager --full --failed | bat -p -l properties --wrap=never'
fi
portcheck() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: portcheck <port>\n' >&2
        return 2
    fi

    lsof -nP -iTCP:"$1" -sTCP:LISTEN
}

killport() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: killport <port>\n' >&2
        return 2
    fi

    local pids
    pids="$(lsof -tiTCP:"$1" -sTCP:LISTEN)"

    if [ -z "$pids" ]; then
        printf 'Nothing is listening on port %s.\n' "$1"
        return 0
    fi

    printf 'Processes listening on port %s:\n%s\n' "$1" "$pids"
    printf 'Terminate these processes? [y/N] '

    local answer
    read -r answer

    case "$answer" in
        y|Y|yes|YES)
            # Split newline-separated PIDs explicitly for zsh.
            kill ${(f)pids}
            ;;
        *)
            printf 'Cancelled.\n'
            ;;
    esac
}

localip() {
    if [ "$AWESOME_ALIAS_OS" = "macos" ]; then
        ipconfig getifaddr en0 2>/dev/null ||
            ipconfig getifaddr en1 2>/dev/null
    elif has hostname; then
        hostname -I 2>/dev/null | awk '{print $1}'
    else
        printf 'Unable to determine local IP address.\n' >&2
        return 1
    fi
}

publicip() {
    if has curl; then
        curl --fail --silent --show-error https://api.ipify.org
        printf '\n'
    elif has wget; then
        wget -qO- https://api.ipify.org
        printf '\n'
    else
        printf 'curl or wget is required.\n' >&2
        return 1
    fi
}
# Cyan: IPv4 addresses; yellow: ports; green: success; red: errors.
_netview() {
    emulate -L zsh
    setopt pipefail

    # Keep redirected output plain.
    if [[ ! -t 1 ]]; then
        "$@"
        return
    fi

    "$@" 2>&1 | perl -pe '
        BEGIN { $| = 1 }

        s/\b(?:\d{1,3}\.){3}\d{1,3}\b/\e[36m$&\e[0m/g;
        s/:(\d+)(?=\s|->|$)/:\e[33m$1\e[0m/g;

        s/\b(LISTEN|ESTABLISHED|bytes from)\b/\e[32m$1\e[0m/g;
        s/\b(unreachable|timed out|timeout|refused|failure|failed|error)\b/\e[31m$1\e[0m/gi;

        s/(\d+(?:\.\d+)?)(% packet loss)/
            ($1 == 0 ? "\e[32m" : "\e[31m") . "$1$2\e[0m"
        /ge;

        s/^(\s*COMMAND\b.*)$/\e[34m$1\e[0m/;
    '
}

_routeinfo() {
    command ip -color=auto route "$@" 2>/dev/null ||
        _netview netstat -rn "$@"
}

alias ping5='ping -c 5'
alias pingdns='_netview ping -c 5 1.1.1.1'
alias routeinfo='ip -color=auto route'

alias dnsinfo="sed '/^[[:space:]]*[#;]/d; /^[[:space:]]*$/d' /etc/resolv.conf | bat -pp -l resolv"
alias hostsfile='bat -pp -l hosts /etc/hosts'

alias listeners='_netview lsof -nP -iTCP -sTCP:LISTEN'
alias connections='_netview lsof -nP -i'
alias gpg-fingerprint="gpg --with-colons --fingerprint | awk -F: '\$1==\"pub\"{p=1} \$1==\"fpr\" && p{print \$10; p=0}'"
# alias md2pdf='f() { local input="$1"; pandoc "$input" -f markdown+gfm_auto_identifiers --shift-heading-level-by=-1 -o "${input%.md}.pdf" --pdf-engine=xelatex -V geometry:margin=1in -V fontsize=11pt --toc --toc-depth=2; unset -f f; }; f'
alias md2pdf='f() {
  local input="$1"
  pandoc "$input" \
    -f markdown+gfm_auto_identifiers \
    --shift-heading-level-by=-1 \
    --pdf-engine=xelatex \
    -V geometry:margin=1in \
    -V fontsize=11pt \
    --toc --toc-depth=2 \
    -o "${input%.md}.pdf"
  unset -f f
}; f'
