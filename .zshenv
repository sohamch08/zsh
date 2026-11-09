# ~/.config/zsh/.zshenv

# ---------- OS detection ----------
# IS_MAC / IS_LINUX are used to guard platform-specific config here and in .zshrc
typeset -g IS_MAC=0 IS_LINUX=0
case "$OSTYPE" in
darwin*) IS_MAC=1 ;;
linux*) IS_LINUX=1 ;;
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

# ---------- PATH ----------
# Keep identical PATH entries unique.
typeset -U path PATH

# Personal binaries/scripts.
path=("$HOME/.local/bin" "$HOME/bin" "${path[@]}")
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
  texbin=(/usr/local/texlive/*/bin/*(N/))
  (($#texbin)) && export PATH="${texbin[-1]}:$PATH"
}

# ---------- Application and personal variables ----------
source "$ZDOTDIR/env.zsh"
