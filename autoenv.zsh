# Generate missing project .envrc files before direnv loads the environment.
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"

  _uv_direnv_hook() {
    emulate -L zsh
    local dir=$PWD envrc

    while true; do
      envrc="$dir/.envrc"
      # Existing files and symlinks keep direnv's normal approval requirements.
      [[ -e "$envrc" || -L "$envrc" ]] && break

      if [[ -f "$dir/.venv/pyvenv.cfg" &&
            -x "$dir/.venv/bin/python" ]]; then
        # Only approve a file this hook has just created; never overwrite one.
        if (setopt noclobber; print -r -- 'layout uv' > "$envrc"); then
          command direnv allow "$envrc"
        fi
        break
      fi

      [[ $dir == / ]] && break
      dir=${dir:h}
    done

    _direnv_hook
  }

  autoload -Uz add-zsh-hook
  add-zsh-hook -d chpwd _direnv_hook
  add-zsh-hook -d precmd _direnv_hook
  add-zsh-hook chpwd _uv_direnv_hook
  add-zsh-hook precmd _uv_direnv_hook
fi
