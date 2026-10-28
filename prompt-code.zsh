# Starship supplies project metadata; Powerlevel10k renders the prompt.
typeset -g _p10k_code_config="${${(%):-%x}:A:h}/p10k-code.toml"
typeset -g _p10k_code_fresh=0 _p10k_code_key='' _p10k_code_text=''

function _p10k_code_invalidate() {
  typeset -g _p10k_code_fresh=0
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _p10k_code_invalidate
add-zsh-hook chpwd _p10k_code_invalidate

function prompt_code() {
  emulate -L zsh
  [[ $TERM != dumb && -r $_p10k_code_config ]] && (( $+commands[starship] )) || return 0

  # Query once per command, and reuse the result during line-editor redraws.
  local key="$PWD|$PATH|$VIRTUAL_ENV|$CONDA_PREFIX|$AWS_PROFILE|$AWS_DEFAULT_PROFILE|$AWS_VAULT|$AWS_REGION|$AWS_DEFAULT_REGION|$DOCKER_CONTEXT|$DOCKER_HOST"
  if (( ! _p10k_code_fresh )) || [[ $_p10k_code_key != "$key" ]]; then
    local output
    output=$(STARSHIP_CONFIG="$_p10k_code_config" STARSHIP_SHELL='' STARSHIP_LOG=error \
      command starship prompt --path "$PWD" 2>/dev/null) || output=''
    typeset -g _p10k_code_text="$output" _p10k_code_key="$key" _p10k_code_fresh=1
  fi

  local entry kind text color
  for entry in "${(@f)_p10k_code_text}"; do
    [[ $entry == *'|'* ]] || continue
    kind=${entry%%|*}
    text=${entry#*|}
    [[ -n $text ]] || continue
    case $kind in
      c|cpp|cmake|lua)           color='#89b4fa' ;;
      python|golang|latex)      color='#94e2d5' ;;
      php|haskell)              color='#cba6f7' ;;
      nodejs)                   color='#a6e3a1' ;;
      rust|package)             color='#fab387' ;;
      ruby)                     color='#f38ba8' ;;
      aws)                      color='#f9e2af' ;;
      docker)                   color='#06969a' ;;
      *) continue ;;
    esac
    p10k segment -s "$kind" -f "$color" -t "${text//\%/%%}"
  done
}
