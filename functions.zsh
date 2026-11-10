# Colors
autoload -Uz colors && colors

C_RED=${fg[red]}
C_GREEN=${fg[green]}
C_YELLOW=${fg[yellow]}
C_CYAN=${fg[cyan]}
C_NC=${reset_color}

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
  SAVEIFS=$IFS
  IFS=$' \t\n'
  set +e # abort execution on errors

  if [ $# -eq 0 ]; then
    # display usage if no parameters given
    echo "Usage: ${C_YELLOW}extract${C_NC} <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz|.zlib|.cso|.zst>"
    echo "       ${C_YELLOW}extract${C_NC} <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"

    return 1
  fi

  while [[ $# -gt 0 ]]; do
    n="$1"
    shift

    # === STDIN ===
    if [[ "$n" == "-" ]]; then
      if [ -z "$1" ]; then
        echo "Error: must provide extension after '-' (stdin mode)"
        return 1
      fi
      ext="$1"
      shift

      tmpfile=$(mktemp "/tmp/extract.stdin.XXXXXX.$ext")
      cat >"$tmpfile"
      echo "Saved stdin to temp file: $tmpfile"
      extract "$tmpfile"
      rm -f "$tmpfile"
      continue
    fi

    # === FILE CHECK ===
    if [ ! -f "$n" ]; then
      echo "'$n' - file doesn't exist"
      continue
    fi

    case "${n%,}" in
    *.cbt | *.tar.bz2 | *.tar.gz | *.tar.xz | *.tbz2 | *.tgz | *.txz | *.tar)
      tar --auto-compress -xvf "$n"
      ;;
    *.lzma) unlzma "$n" ;;
    *.appimage) ./"$n" --appimage-extract ;;
    *.tar.lz4) tar --use-compress-program=lz4 -xvf "$n" ;;
    *.lz4) lz4 -d "$n" ;;
    *.tar.br) tar --use-compress-program=brotli -xvf "$n" ;;
    *.bz2) bunzip2 "$n" ;;
    *.cbr | *.rar) unrar x -ad "$n" ;;
    *.gz) gunzip "$n" ;;
    *.cbz | *.epub | *.zip) unzip "$n" ;;
    *.z) uncompress "$n" ;;
    *.7z | *.apk | *.arj | *.cab | *.cb7 | *.chm | *.deb | *.iso | *.lzh | *.msi | *.pkg | *.rpm | *.udf | *.wim | *.xar | *.vhd)
      7z x "$n"
      ;;
    *.xz) unxz "$n" ;;
    *.exe) cabextract "$n" ;;
    *.cpio) cpio -id <"$n" ;;
    *.cba | *.ace) unace x "$n" ;;
    *.zpaq) zpaq x "$n" ;;
    *.arc) arc e "$n" ;;
    *.cso) ciso 0 "$n" "$n.iso" && extract "$n.iso" && rm -f "$n" ;;
    *.zlib) zlib-flate -uncompress <"$n" >"${n%.*zlib}" && rm -f "$n" ;;
    *.dmg)
      mnt_dir=$(mktemp -d)
      hdiutil mount "$n" -mountpoint "$mnt_dir"
      echo "Mounted at: $mnt_dir"
      ;;
    *.tar.zst) tar -I zstd -xvf "$n" ;;
    *.zst) zstd -d "$n" ;;
    *)
      echo "${C_RED}❌ '$n' cannot be extracted via extract().${C_NC}"
      echo "${C_RED}❌ '$n' is not a valid file.${C_NC}"
      continue
      ;;
    esac
  done
  echo "${C_GREEN}✅ Extraction complete!${C_NC}"

  IFS=$SAVEIFS
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
