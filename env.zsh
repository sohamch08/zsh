export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

export EZA_CONFIG_DIR=$HOME/.config/eza
export EZA_ICON_SPACING=2

# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/.gems"

export SOULSEEK_USERNAME="sohamc"
export SOULSEEK_PASSWORD_CMD="pass show soulseek"

export CMUS_HOME="${XDG_CONFIG_HOME:-$HOME/.local/state}/cmus"
export PF_INFO="ascii title os host kernel memory wm de shell editor"

# --------- My Personal Variables ---------------
export SOHAM_PAPERS_DIR="$HOME/My Papers"
export SOHAM_VAULTS_DIR="$HOME/Documents/Research"
export SOHAM_PAPERS_CACHE="$HOME/.cache/hyprlife/papers.json"
export SOHAM_QUARTZ_DIR="$HOME/github/quartz"

# ----------- PATH ---------------
export PATH="$HOME/.cargo/bin:$HOME/go/bin:$GEM_HOME/bin:$PATH"
