# ----- Command availability -----
has() {
  command -v "$1" >/dev/null 2>&1
}

# ----- Command help -----
help() {
  "$@" --help 2>&1 | bathelp
}

# ----- File renaming -----
rename_series() {
  if (($# != 1)); then
    print -u2 'Usage: rename_series PREFIX'
    return 1
  fi

  local file ext new_name
  local -i i=1

  for file in *.*(N.); do
    ext="${file##*.}"
    printf -v new_name '%s%02d.%s' "$1" "$i" "$ext"
    if [[ "$file" != "$new_name" ]]; then
      command mv -i -- "$file" "$new_name" || return
    fi
    ((i++))
  done
}

# ----- Archive extraction -----
extract() {
  [[ -f "$1" ]] || {
    echo "File not found"
    return 1
  }

  case "$1" in
  *.tar.gz | *.tgz) tar -xzf "$1" ;;
  *.tar.bz2) tar -xjf "$1" ;;
  *.tar.xz) tar -xJf "$1" ;;
  *.7z) 7z x "$1" ;;
  *.zip) unzip "$1" ;;
  *.gz) gunzip "$1" ;;
  *.bz2) bunzip2 "$1" ;;
  *) echo "Unsupported format" ;;
  esac
}

# ----- Flatpak -----
flatpak() {
  if [[ "$1" == "list" && $# -eq 1 ]]; then
    command flatpak list --runtime --columns=name,application,branch,size
  else
    command flatpak "$@"
  fi
}

# ----- KeePassXC -----
kpxc() {
  flatpak run --command=keepassxc-cli org.keepassxc.KeePassXC "$@"
}

# ----- C compilation -----
cstudy() {
  command gcc \
    -std=c17 -g -O2 \
    -Wall -Wextra -Wpedantic \
    -Wformat=2 -Wshadow -Wwrite-strings \
    -Wstrict-prototypes -Wold-style-definition \
    -Wredundant-decls -Wnested-externs \
    -Wmissing-include-dirs \
    -Wjump-misses-init -Wlogical-op \
    "$@"
}
