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

port() {
  if [[ "$1" == "help" || "$1" == "-h" || -z "$1" ]]; then
    echo "${C_CYAN}🔌 port${C_NC}: See what's running on a port and optionally kill it."
    echo "Usage: ${C_YELLOW}port <number> [kill]${C_NC}"
    echo "Examples:"
    echo "  port 8080       (Views processes on port 8080)"
    echo "  port 3000 kill  (Kills the process running on port 3000)"
    return 0
  fi

  local target_port=$1
  if [[ "$2" == "kill" ]]; then
    echo "${C_RED}Attempting to kill process on port $target_port...${C_NC}"
    local pid=$(lsof -t -i:"$target_port")
    if [[ -n "$pid" ]]; then
      kill -9 $pid
      echo "${C_GREEN}✅ Process $pid killed successfully.${C_NC}"
    else
      echo "${C_YELLOW}⚠️  No process found running on port $target_port.${C_NC}"
    fi
  else
    echo "${C_CYAN}Processes listening on port $target_port:${C_NC}"
    lsof -i :"$target_port" || echo "${C_YELLOW}No active processes on this port.${C_NC}"
  fi
}

# Display local, public, and approximate geolocation information for your IP
myip() {
  emulate -L zsh

  if [[ ${1-} == help || ${1-} == -h || ${1-} == --help ]]; then
    print -r -- 'Usage: myip'
    print -r -- 'Show local, Tailscale, and public IP addresses with approximate location.'
    return 0
  fi
  if (($#)); then
    print -u2 -- 'Usage: myip'
    return 2
  fi

  local interface local_ip tail4 tail6 public_ip endpoint city country
  local -a curl_options=(-4 --fail --silent --show-error
    --connect-timeout 3 --max-time 8)

  interface=$(command ip -4 route show default 2>/dev/null |
    command awk '{for (i=1; i<NF; i++) if ($i == "dev") {print $(i+1); exit}}')

  if [[ -n $interface ]]; then
    local_ip=$(command ip -4 -o addr show dev "$interface" scope global 2>/dev/null |
      command awk 'NR==1 {split($4, a, "/"); print a[1]}')
  fi

  if (($+commands[tailscale])); then
    tail4=$(command tailscale ip -4 2>/dev/null)
    tail6=$(command tailscale ip -6 2>/dev/null)
  fi

  print -r -- "🏠 ${C_YELLOW-}Local IPv4:${C_NC-}     ${local_ip:-unavailable}"
  print -r -- "🔗 ${C_YELLOW-}Tailscale IPv4:${C_NC-} ${tail4:-unavailable}"
  print -r -- "🔗 ${C_YELLOW-}Tailscale IPv6:${C_NC-} ${tail6:-unavailable}"

  for endpoint in https://api.ipify.org https://ipinfo.io/ip; do
    if public_ip=$(command curl "${curl_options[@]}" "$endpoint") &&
      [[ $public_ip == <0-255>.<0-255>.<0-255>.<0-255> ]]; then
      break
    fi
    public_ip=''
  done

  if [[ -z $public_ip ]]; then
    print -u2 -- 'myip: public IPv4 lookup failed on both services.'
    return 1
  fi

  print -r -- "🌍 ${C_YELLOW-}Public IPv4:${C_NC-}    $public_ip"

  city=$(command curl "${curl_options[@]}" "https://ipinfo.io/$public_ip/city") ||
    city=''
  country=$(command curl "${curl_options[@]}" "https://ipinfo.io/$public_ip/country") ||
    country=''

  print -r -- "📍 ${C_YELLOW-}Location:${C_NC-}       ${city:-unavailable}, ${country:-unavailable}"
}

# Fetch terminal weather and forecast information with optional display formats
weather() {
  if [[ "$1" == "help" || "$1" == "-h" ]]; then
    echo "${C_CYAN}☁️  weather${C_NC}: Advanced terminal weather and forecast."
    echo "Usage: ${C_YELLOW}weather [options] [location]${C_NC}"
    echo ""
    echo "Options:"
    echo "  ${C_YELLOW}-s, --short${C_NC}    Single-line compact format (Temp & Condition)"
    echo "  ${C_YELLOW}-o, --oneline${C_NC}  Rich single-line format (Temp, Wind, Humidity)"
    echo "  ${C_YELLOW}-f, --forecast${C_NC} Detailed visual graph forecast"
    echo "  ${C_YELLOW}-m, --moon${C_NC}    Show current moon phase"
    echo ""
    echo "Examples:"
    echo "  weather London          (Default 3-day text forecast)"
    echo "  weather -o New York     (One-line rich weather)"
    echo "  weather -f              (Detailed forecast for your current IP)"
    return 0
  fi

  local format=""
  local args=()

  for arg in "$@"; do
    case "$arg" in
    -s | --short) format="?format=3" ;;
    -o | --oneline) format="?format=4" ;;
    -f | --forecast) format="?format=v2" ;;
    -m | --moon) format="?Moon" ;;
    -*)
      echo "${C_RED}❌ Unknown option: $arg${C_NC}"
      echo "Run ${C_YELLOW}weather -h${C_NC} for usage."
      return 1
      ;;
    *) args+=("$arg") ;;
    esac
  done

  local loc="${args[*]}"
  loc="${loc// /+}"

  echo "${C_CYAN}Fetching weather data...${C_NC}"
  curl -s "https://wttr.in/${loc}${format}"
}
