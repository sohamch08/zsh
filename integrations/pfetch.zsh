pfetch-cache-refresh() {
  emulate -L zsh
  (( $+commands[pfetch] )) || return 1

  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/pfetch.txt"
  local tmp="${cache}.$$.${RANDOM}.tmp"
  command mkdir -p -- "${cache:h}" || return

  if command pfetch > "$tmp"; then
    command mv -f -- "$tmp" "$cache"
  else
    command rm -f -- "$tmp"
    return 1
  fi
}

pfetch-banner() {
  emulate -L zsh
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/pfetch.txt"

  if [[ ! -s $cache ]]; then
    pfetch-cache-refresh || return
  fi
  local banner
  IFS= read -r -d '' banner < "$cache"
  print -rn -- "$banner"

  zmodload zsh/datetime || return 0
  zmodload zsh/stat || return 0
  local -A info
  if zstat -H info -- "$cache" &&
      (( EPOCHSECONDS - info[mtime] >= 300 )); then
    (pfetch-cache-refresh >/dev/null 2>&1) &!
  fi
  return 0
}
