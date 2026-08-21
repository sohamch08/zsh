export VIRTUAL_ENV_DISABLE_PROMPT=1
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"

FUNCNEST=1000

eval "$(starship init zsh)"
