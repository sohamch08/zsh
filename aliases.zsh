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


# ─── RCLONE GENERAL ALIASES ───────────────────────────────────────────────────

# List all configured remotes
alias rcremotes='rclone listremotes'

# Show rclone config
alias rcconfig='sed "s/token = .*/token = ██████████████████████████████/" ~/.config/rclone/rclone.conf | bat --language=ini'
# alias rcconfig='bat ~/.config/rclone/rclone.conf'

# Edit rclone config
alias rcedit='nvim ~/.config/rclone/rclone.conf'

# Show rclone log
alias rclog='tail -f ~/.config/rclone/rclone.log'

# Clear rclone log
alias rclog-clear='> ~/.config/rclone/rclone.log'

# Show all rclone aliases and usage
rchelp() {
    bat --language=bash --style=plain <<'EOF'
# ── GENERAL ──────────────────────────────────────────────
rchelp                                  # Show this help
rcremotes                               # List all configured remotes
rcconfig                                # Show rclone config
rcedit                                  # Edit config in nvim
rclog                                   # Live tail of log
rclog-clear                             # Clear log

# ── LISTING ──────────────────────────────────────────────
rcls visa:                              # List files on remote
rctree gdrive:                          # Tree view via eza

# ── MOUNT ────────────────────────────────────────────────
rcmount visa:                           # Mount remote
rcumount visa:                          # Unmount remote
# Mounts to: ~/.rclone-mounts/<remotename>

# ── TRANSFER ─────────────────────────────────────────────
rcpull "visa:Visa Application" ~/local  # Download remote → local
rcpush ~/local "visa:Visa Application"  # Upload local → remote

# ── SYNC (DESTRUCTIVE) ───────────────────────────────────
rcsync-down "visa:Visa Application" ~/local  # Mirror remote → local
rcsync-up ~/local "visa:Visa Application"    # Mirror local → remote
# ⚠ Always dry run first!

# ── DRY RUN (SAFE PREVIEW) ───────────────────────────────
rcdry-down "visa:Visa Application" ~/local   # Preview download
rcdry-up ~/local "visa:Visa Application"     # Preview upload

# ── STATUS (GIT-LIKE) ────────────────────────────────────
rcgit "visa:Visa Application" ~/local        # Full git-like summary
rcstatus "visa:Visa Application" ~/local     # Diff with symbols
rcremote-only "visa:Visa Application" ~/local  # Remote ahead
rclocal-only "visa:Visa Application" ~/local   # Local ahead
rcdiff "visa:Visa Application" ~/local         # Files that differ

# Symbols:  = identical  < local ahead  > remote ahead  * different
EOF
}

# ─── RCLONE FUNCTIONS (remote specific) ───────────────────────────────────────

# List files on any remote (human readable)
rcls() {
    rclone ls "$1" --human-readable
}

# Tree view of any remote via eza (mounts temporarily)
rctree() {
    local remote="$1"
    local mount="$HOME/${remote}-mounts"
    mkdir -p "$mount"
    rclone mount "$remote:" "$mount" --daemon --vfs-cache-mode full
    lt "$mount"
}

# Mount a remote
rcmount() {
    local remote="$1"
    local mount="$HOME/${remote}-mounts/"
    mkdir -p "$mount"
    rclone mount "$remote:" "$mount" --daemon --vfs-cache-mode full
    echo "Mounted $remote: at $mount"
}

# Unmount a remote
rcumount() {
    local remote="$1"
    local mount="$HOME/${remote}-mounts/"
    fusermount -u "$mount" && echo "Unmounted $remote:"
}

# Copy remote → local
rcpull() {
    rclone copy "$1" "$2" --progress
}

# Copy local → remote
rcpush() {
    rclone copy "$1" "$2" --progress
}

# Sync remote → local
rcsync-down() {
    rclone sync "$1" "$2" --progress
}

# Sync local → remote
rcsync-up() {
    rclone sync "$1" "$2" --progress
}

# Dry run: preview download
rcdry-down() {
    rclone copy "$1" "$2" --dry-run --progress
}

# Dry run: preview upload
rcdry-up() {
    rclone copy "$1" "$2" --dry-run --progress
}

# ─── RCLONE STATUS (git-like) ─────────────────────────────────────────────────

# Full status with symbols
rcstatus() {
    echo "=  identical"
    echo "<  only on local (local ahead)"
    echo ">  only on remote (remote ahead)"
    echo "*  different on both"
    echo "──────────────────────────────"
    rclone check "$1" "$2" --combined -
}

# Files only on remote
rcremote-only() {
    echo "Remote ahead — files only on $1:"
    rclone check "$1" "$2" --missing-on-destination -
}

# Files only on local
rclocal-only() {
    echo "Local ahead — files only in $2:"
    rclone check "$1" "$2" --missing-on-source -
}

# Files that differ
rcdiff() {
    echo "Files that differ between $1 and $2:"
    rclone check "$1" "$2" --differ -
}

# Full git-like summary
rcgit() {
    local remote="$1"
    local local_path="$2"
    echo ""
    echo "📡 Remote: $remote"
    echo "💻 Local:  $local_path"
    echo "──────────────────────────────────────"

    echo ""
    echo "🔼 Local ahead (only on local):"
    rclone check "$remote" "$local_path" --missing-on-source - 2>/dev/null || echo "  none"

    echo ""
    echo "🔽 Remote ahead (only on remote):"
    rclone check "$remote" "$local_path" --missing-on-destination - 2>/dev/null || echo "  none"

    echo ""
    echo "📝 Different on both:"
    rclone check "$remote" "$local_path" --differ - 2>/dev/null || echo "  none"

    echo "──────────────────────────────────────"
}



# ─── Extra FUNCTIONS  ──────────────────────────────────────────────────────
alias b="bat"
alias c="clear"
alias e="nvim"
alias l="ll"
alias la="lla"
alias su="sudo su"
alias reboot='sudo /sbin/reboot'
alias poweroff='sudo /sbin/poweroff'
alias ve='python3 -m venv ./venv'
alias va='source ./venv/bin/activate'
alias y="yazi"
mkcd () {
  mkdir -p -- "$1" && cd -- "$1"
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
alias rm="rm -Iv"
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
