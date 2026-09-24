# Quoted "~" is not expanded by zsh, so use $HOME/XDG vars instead
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt CORRECT

# =========================================================
# Shell behaviour
# =========================================================

setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT  # sort file10 after file9, not after file1


# =========================================================
# Completion
# =========================================================

# Load completion system
autoload -Uz compinit

# Initialize completion with cached metadata file
() {
  local zcd="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
  [[ -d "${zcd:h}" ]] || mkdir -p "${zcd:h}"
  compinit -d "$zcd"
}

# Enable interactive completion menu selection
zstyle ':completion:*' menu select

# Make completion case-insensitive
# Example: "doc" can complete to "Documents"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # lowercase input matches upper and lower

# =========================================================
# Smart directory navigation & Yazi
# =========================================================


# Initialize zoxide
eval "$(zoxide init --cmd cd zsh)"
eval "$(fzf --zsh)"
eval "$(atuin init zsh)"
# =========================================================
# Fuzzy finder
# =========================================================

source $ZDOTDIR/key-bindings.zsh
source $ZDOTDIR/completion.zsh

# =========================================================
# Modular Config Files
# =========================================================

# fzf configuration
source "$ZDOTDIR/fzf.zsh"

# Aliases
source "$ZDOTDIR/aliases.zsh"

# tifr VPN helper
source "$ZDOTDIR/tifr-vpn.zsh"

# Plugins and plugin manager
source "$ZDOTDIR/plugins.zsh"

# Custom keybindings
source "$ZDOTDIR/bindings.zsh"

# Prompt/theme
source "$ZDOTDIR/prompt.zsh"

source "$ZDOTDIR/fzf-git.sh"

# =========================================================
# chruby (macOS: Homebrew, Linux: system prefix)
# =========================================================

() {
  local -a prefixes
  if (( IS_MAC )); then
    prefixes=( /opt/homebrew/opt/chruby/share/chruby /usr/local/opt/chruby/share/chruby )
  else
    prefixes=( /usr/share/chruby /usr/local/share/chruby )
  fi

  local dir
  for dir in $prefixes; do
    [[ -r "$dir/chruby.sh" ]] || continue
    source "$dir/chruby.sh"
    [[ -r "$dir/auto.sh" ]] && source "$dir/auto.sh"
    chruby ruby-3.4.1 2>/dev/null
    break
  done
}
# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/.cargo/bin:$HOME/gems/bin:$PATH"
export SOULSEEK_USERNAME="sohamc"
export SOULSEEK_PASSWORD="19158113"
export SOULSEEK_PASSWORD_CMD="19158113"

fastfetch
