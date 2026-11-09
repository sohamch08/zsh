if [[ -o interactive && -t 0 ]]; then
    export GPG_TTY="$(tty)"

    mail-unlock() {
        command gopass show -o mail/TIFR >/dev/null
    }
fi

neomutt() {
    local nm_term=xterm-direct

    if [[ -n "${TMUX:-}" ]]; then
        nm_term=tmux-direct
    fi

    /usr/bin/env \
        TERMINFO=/opt/homebrew/opt/ncurses/share/terminfo \
        TERM="$nm_term" \
        /opt/homebrew/bin/neomutt "$@"
}
