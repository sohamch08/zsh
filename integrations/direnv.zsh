# Discover uv environments at most once every two seconds in the same directory.
if (($+commands[direnv])); then
  source "$HOME/.cache/zsh/init/direnv.zsh"
  zmodload zsh/datetime

  typeset -g _uv_direnv_scan_pwd=''
  typeset -gi _uv_direnv_scan_time=0

  _uv_direnv_hook() {
    emulate -L zsh

    if [[ $PWD != $_uv_direnv_scan_pwd ]] ||
      ((EPOCHSECONDS - _uv_direnv_scan_time >= 2)); then
      _uv_direnv_scan_pwd=$PWD
      _uv_direnv_scan_time=$EPOCHSECONDS
      local dir=$PWD envrc

      while true; do
        envrc="$dir/.envrc"
        [[ -e "$envrc" || -L "$envrc" ]] && break

        if [[ -f "$dir/.venv/pyvenv.cfg" && -x "$dir/.venv/bin/python" ]]; then
          if (
            setopt noclobber
            print -r -- 'layout uv' >"$envrc"
          ); then
            command direnv allow "$envrc"
          fi
          break
        fi

        [[ $dir == / ]] && break
        dir=${dir:h}
      done
    fi

    # Apply changes on directory changes and explicit uv-direnv-rescan calls.
    _direnv_hook
  }

  uv-direnv-rescan() {
    _uv_direnv_scan_pwd=''
    _uv_direnv_hook
  }

  autoload -Uz add-zsh-hook
  add-zsh-hook -d chpwd _direnv_hook
  add-zsh-hook -d precmd _direnv_hook
  add-zsh-hook chpwd _uv_direnv_hook
fi
