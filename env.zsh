export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm

export EZA_CONFIG_DIR=$HOME/.config/eza
export EZA_ICON_SPACING=2

# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/.gems"

export SOULSEEK_USERNAME="sohamc"
export SOULSEEK_PASSWORD_CMD="pass show soulseek"

export CMUS_HOME="${XDG_CONFIG_HOME:-$HOME/.local/state}/cmus"
export PF_INFO="ascii title os host kernel memory wm de shell editor"

# --------- My Personal Variables ---------------
export SOHAM_PAPERS_DIR="${SOHAM_PAPERS_DIR:-$HOME/My Papers}"
if [[ -z ${SOHAM_VAULTS_DIR:-} ]]; then
  if [[ -n ${SOHAM_PAPERS_NOTES_DIR:-} ]]; then
    SOHAM_VAULTS_DIR="$SOHAM_PAPERS_NOTES_DIR"
  elif [[ $OSTYPE == darwin* ]]; then
    SOHAM_VAULTS_DIR="$HOME/Documents/Research"
  else
    SOHAM_VAULTS_DIR="$HOME/projects/Research"
  fi
fi
export SOHAM_VAULTS_DIR
# Keep the variable used by the Linux configuration available to other tools.
export SOHAM_PAPERS_NOTES_DIR="$SOHAM_VAULTS_DIR"
export SOHAM_PAPERS_CACHE="$HOME/.cache/hyprlife/papers.json"
export SOHAM_QUARTZ_DIR="$HOME/github/quartz"

# ----------- PATH ---------------
export PATH="$HOME/.cargo/bin:$HOME/go/bin:$GEM_HOME/bin:$PATH"
