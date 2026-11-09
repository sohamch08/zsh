# Starship runs in a child process; Powerlevel10k renders cached records.
zmodload zsh/system

autoload -Uz add-zsh-hook
add-zsh-hook -d preexec _p10k_code_invalidate
add-zsh-hook -d chpwd _p10k_code_invalidate
add-zsh-hook -d precmd _p10k_code_refresh

if [[ -n ${_p10k_code_fd-} ]]; then
  zle -F "$_p10k_code_fd" 2>/dev/null
  exec {_p10k_code_fd}<&-
fi

typeset -g _p10k_code_config="${${(%):-%x}:A:h}/p10k-code.toml"
typeset -g _p10k_code_fd='' _p10k_code_buffer=''
typeset -g _p10k_code_env_key='' _p10k_code_job_key=''
typeset -gi _p10k_code_pending=0
typeset -gA _p10k_code_segments=()

_p10k_code_key_now() {
  REPLY="$PWD|$PATH|$VIRTUAL_ENV|$CONDA_PREFIX|$AWS_PROFILE|$AWS_DEFAULT_PROFILE|$AWS_VAULT|$AWS_REGION|$AWS_DEFAULT_REGION|$DOCKER_CONTEXT|$DOCKER_HOST"
}

_p10k_code_refresh() {
  emulate -L zsh
  [[ $TERM != dumb && -r $_p10k_code_config ]] || return 0
  (( $+commands[starship] )) || return 0
  local REPLY
  _p10k_code_key_now
  if [[ $REPLY != $_p10k_code_env_key ]]; then
    _p10k_code_env_key=$REPLY
    _p10k_code_segments=()
  fi
  if [[ -n $_p10k_code_fd ]]; then
    _p10k_code_pending=1
    return 0
  fi
  _p10k_code_pending=0
  _p10k_code_job_key=$REPLY
  _p10k_code_buffer=''
  exec {_p10k_code_fd}< <(
    result=$(STARSHIP_CONFIG="$_p10k_code_config" STARSHIP_SHELL='' STARSHIP_LOG=error \
      command starship prompt --path "$PWD" 2>/dev/null)
    result_code=$?
    print -rn -- "$result_code"$'\n'"$result" 2>/dev/null
  )
  zle -F "$_p10k_code_fd" _p10k_code_collect
}

_p10k_code_collect() {
  emulate -L zsh
  [[ $1 == $_p10k_code_fd ]] || return 0
  local chunk read_result
  while true; do
    sysread -i "$1" -s 65536 -t 0 chunk
    read_result=$?
    case $read_result in
      0) _p10k_code_buffer+=$chunk ;;
      4) return 0 ;;
      *) break ;;
    esac
  done
  zle -F "$1"
  exec {_p10k_code_fd}<&-
  _p10k_code_fd=''
  local REPLY
  _p10k_code_key_now
  if (( _p10k_code_pending )) || [[ $REPLY != $_p10k_code_job_key ]]; then
    _p10k_code_refresh
    return 0
  fi
  _p10k_code_segments=()
  if (( read_result == 5 )) && [[ $_p10k_code_buffer == 0$'\n'* ]]; then
    local records=${_p10k_code_buffer#*$'\n'} line kind text
    for line in "${(@f)records}"; do
      [[ $line == *'|'* ]] || continue
      kind=${line%%|*}
      text=${line#*|}
      case $kind in
        c|cpp|cmake|python|php|lua|nodejs|golang|haskell|rust|ruby|latex|package|aws|docker)
          _p10k_code_segments[$kind]=${text//\%/%%}
          ;;
      esac
    done
  fi
  _p10k_code_buffer=''
  if zle; then
    p10k display -r
  fi
}

prompt_code() {
  emulate -L zsh
  local kind color reference
  for kind in c cpp cmake python php lua nodejs golang haskell rust ruby latex package aws docker; do
    case $kind in
      c|cpp|cmake|lua) color='#89b4fa' ;;
      python|golang|latex) color='#94e2d5' ;;
      php|haskell) color='#cba6f7' ;;
      nodejs) color='#a6e3a1' ;;
      rust|package) color='#fab387' ;;
      ruby) color='#f38ba8' ;;
      aws) color='#f9e2af' ;;
      docker) color='#06969a' ;;
    esac
    reference='${_p10k_code_segments['$kind']-}'
    p10k segment -s "$kind" -f "$color" -e -c "$reference" -t "$reference"
  done
}

add-zsh-hook precmd _p10k_code_refresh
