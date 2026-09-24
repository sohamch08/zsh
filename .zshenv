# ~/.config/zsh/.zshenv

# ---------- OS detection ----------
# IS_MAC / IS_LINUX are used to guard platform-specific config here and in .zshrc
typeset -g IS_MAC=0 IS_LINUX=0
case "$OSTYPE" in
  darwin*) IS_MAC=1 ;;
  linux*)  IS_LINUX=1 ;;
esac

# ---------- XDG base directories ----------
# Centralizes config/cache/data locations
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_MUSIC_DIR="$HOME/Music"

# ---------- Editor ----------
# Default editor used by git, crontab, etc.
export EDITOR="nvim"
export VISUAL="nvim"

# ---------- Pager ----------
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="bat -l man -p"
elif command -v batcat >/dev/null 2>&1; then
  export MANPAGER="batcat -l man -p"
fi

# ---------- GPG ----------
export GPG_TTY=$(tty)

# ---------- Starship ----------
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"

# ---------- PATH ----------
# Personal binaries/scripts
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# ---------- Lean / elan ----------
# Same location on macOS and Linux; skipped when the toolchain isn't installed
if [[ -d "$HOME/.elan/bin" ]]; then
  export PATH="$HOME/.elan/bin:$PATH"
fi

# ---------- TeX Live ----------
# The platform subdir differs per OS (universal-darwin vs x86_64-linux), and the
# year changes yearly, so resolve the newest install that actually exists.
() {
  local -a texbin
  texbin=( /usr/local/texlive/*/bin/*(N/) )
  (( $#texbin )) && export PATH="${texbin[-1]}:$PATH"
}

# ---------- Ruby ----------
# macOS: Homebrew's keg-only ruby@3.4 (system ruby is too old for jekyll-theme-chirpy)
if (( IS_MAC )) && [[ -d /opt/homebrew/opt/ruby@3.4/bin ]]; then
  export PATH="/opt/homebrew/opt/ruby@3.4/bin:$PATH"
fi


export EZA_CONFIG_DIR=$HOME/.config/eza
export EZA_ICON_SPACING=2
