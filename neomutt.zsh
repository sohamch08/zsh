if [[ -o interactive && -t 0 ]]; then
    export GPG_TTY="$(tty)"

    mail-unlock() {
        local password_file="${PASSWORD_STORE_DIR:-$HOME/.password-store}/tifr.gpg"

        gpg --quiet --no-batch --pinentry-mode loopback \
            --decrypt "$password_file" >/dev/null
    }

    if [[ -r "${PASSWORD_STORE_DIR:-$HOME/.password-store}/tifr.gpg" ]]; then
        mail-unlock
    fi
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
