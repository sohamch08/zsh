function tifr-setup() {
  if (( $# != 0 )) && [[ $# != 4 || $1 != --configure || $3 != --username ]]; then
    print -u2 -- 'Usage: tifr-setup [--configure /path/to/NcpImport.log --username YOUR_TIFR_USERNAME]'
    return 2
  fi

  if ! (( $+commands[swanctl] && $+commands[setfacl] && $+commands[python3] )); then
    sudo dnf install strongswan acl python3 || return 1
    rehash
  fi
  sudo -v || return 1

  # Credentials stay in the existing root-only configuration, outside this repository.
  if (( $# )); then
    local setup_script="$HOME/bin/configure-tifr-vpn.py"
    if [[ ! -f "$setup_script" ]]; then
      print -u2 -- "Missing setup script: $setup_script (see the Fedora VPN guide)."
      return 1
    fi
    sudo python3 "$setup_script" "$2" --username "$4" || return 1
  fi

  # Reload the complete configuration so other saved VPN profiles stay loaded.
  sudo /usr/bin/bash -s -- "$(id -un)" <<'TIFR_SETUP'
set -euo pipefail
vpn_user=$1
profile=/etc/strongswan/swanctl/conf.d/tifr.conf
socket=/run/strongswan/charon.vici
dropin=/etc/systemd/system/strongswan.service.d/tifr-vici-access.conf

if [[ ! -s "$profile" || -L "$profile" ]]; then
  echo 'Missing regular tifr.conf. Run tifr-setup --configure /path/to/NcpImport.log --username YOUR_TIFR_USERNAME.' >&2
  exit 1
fi
chown root:root "$profile"
chmod 600 "$profile"
restorecon "$profile"
systemctl start strongswan.service
swanctl --load-all --noprompt
connections=$(swanctl --list-conns)
if ! grep -q '^tifr:' <<< "$connections" || ! grep -q '^  tifr-net:' <<< "$connections"; then
  echo 'TIFR profile was not loaded. Check the top-level include conf.d/*.conf in /etc/strongswan/swanctl/swanctl.conf.' >&2
  exit 1
fi

# VICI access gives this account VPN control, as in section 12 of the guide.
setfacl_path=$(command -v setfacl)
expected=$(printf '[Service]\nExecStartPost=-%s -m u:%s:rw %s\n' "$setfacl_path" "$vpn_user" "$socket")
if [[ -e "$dropin" || -L "$dropin" ]]; then
  if [[ -L "$dropin" || "$(cat "$dropin")" != "$expected" ]]; then
    echo "Existing $dropin has different settings; review it before replacing it." >&2
    exit 1
  fi
else
  mkdir -p "${dropin%/*}"
  (umask 022; printf '%s\n' "$expected" > "$dropin")
fi
chown root:root "$dropin"
chmod 644 "$dropin"
restorecon "$dropin"
systemctl daemon-reload
setfacl -m "u:${vpn_user}:rw" "$socket"
systemctl enable strongswan.service
TIFR_SETUP
  local setup_result=$?
  (( setup_result == 0 )) || return "$setup_result"
  swanctl --stats >/dev/null 2>&1 || {
    print -u2 -- 'tifr VPN: setup finished, but VICI access still fails.'
    return 1
  }
  print -P '%F{green}✔%f tifr VPN: saved configuration loaded; service and access ready'
}

function _tifr_ensure_daemon() {
  if (( $+commands[swanctl] )) && swanctl --stats >/dev/null 2>&1; then
    return 0
  fi
  print -P '%F{yellow}⋯%f tifr VPN: repairing daemon/access (sudo may be needed)'
  tifr-setup
}

function _tifr_is_connected() {
  # An IKE session alone is not enough: the TIFR child must also be installed.
  [[ "$1" == *state=ESTABLISHED* && "$1" =~ 'tifr-net[^{}]*\{[^{}]*state=INSTALLED' ]]
}

function _tifr_error() {
  local details
  details=$(grep -Ei 'failed|error|denied|refused|no .*found|no .*named' <<< "$1" | tail -5)
  print -u2 -r -- "${details:-${1:-No diagnostic output from swanctl.}}"
}

function tifr-on() {
  _tifr_ensure_daemon || return 1

  local raw connections out attempt
  raw=$(swanctl --list-sas --ike tifr --raw 2>&1) || {
    _tifr_error "$raw"
    return 1
  }
  if _tifr_is_connected "$raw"; then
    _tifr_connect_info ''
    return 0
  fi

  connections=$(swanctl --list-conns 2>&1) || {
    _tifr_error "$connections"
    return 1
  }
  if ! grep -q '^tifr:' <<< "$connections" || ! grep -q '^  tifr-net:' <<< "$connections"; then
    tifr-setup || return 1
  fi

  for attempt in 1 2; do
    if out=$(swanctl --initiate --child tifr-net 2>&1); then
      raw=$(swanctl --list-sas --ike tifr --raw 2>&1)
      if ! _tifr_is_connected "$raw"; then
        print -u2 -- 'tifr VPN: initiation returned, but no installed tifr-net tunnel was found.'
        _tifr_error "$raw"
        return 1
      fi
      _tifr_connect_info "$out"
      notify-send -a tifrvpn "tifr VPN" "Connected" 2>/dev/null || true
      return 0
    fi
    if (( attempt == 1 )) && [[ "$out" == *NO_PROPOSAL_CHOSEN* ]]; then
      print -P '%F{yellow}⋯%f tifr VPN: reloading saved settings and retrying once'
      tifr-setup || return 1
      continue
    fi
    print -P '%F{red}✗%f tifr VPN: failed to connect'
    _tifr_error "$out"
    if [[ "$out" == *NO_PROPOSAL_CHOSEN* ]]; then
      print -u2 -- 'TIFR still rejects the saved IKE/ESP proposal after reloading. Obtain a fresh working mobile export or updated settings from TIFR.'
      print -u2 -- 'To regenerate from your export: tifr-setup --configure /path/to/NcpImport.log --username YOUR_TIFR_USERNAME'
    fi
    return 1
  done
}

function _tifr_connect_info() {
  local out="$1" raw
  raw=$(swanctl --list-sas --ike tifr --raw 2>/dev/null)

  local local_id vip remote_host encr keysize integ dh rekey dns
  local_id=$(grep -oP 'local-id=\K\S+' <<< "$raw" | head -1)
  vip=$(grep -oP 'local-vips=\[\K[0-9.]+' <<< "$raw" | head -1)
  remote_host=$(grep -oP 'remote-host=\K[0-9.]+' <<< "$raw" | head -1)
  encr=$(grep -oP 'encr-alg=\K\w+' <<< "$raw" | head -1)
  keysize=$(grep -oP 'encr-keysize=\K[0-9]+' <<< "$raw" | head -1)
  integ=$(grep -oP 'integ-alg=\K\w+' <<< "$raw" | head -1)
  dh=$(grep -oP 'dh-group=\K\w+' <<< "$raw" | head -1)
  rekey=$(grep -oP 'rekey-time=\K[0-9]+' <<< "$raw" | head -1)
  dns=$(grep -oP 'installing DNS server \K[0-9.]+' <<< "$out" | paste -sd, - 2>/dev/null | sed 's/,/, /g')

  print -P "%F{green}●%f tifr VPN: %B%F{green}Connected%b%f"
  print -P "  %F{magenta}User   %f ${local_id}"
  print -P "  %F{blue}VIP    %f %B${vip}%b"
  print -P "  %F{blue}Gateway%f ${remote_host}"
  print -P "  %F{cyan}Cipher %f ${encr}-${keysize} / ${integ} / ${dh}"
  [[ -n "$dns" ]] && print -P "  %F{yellow}DNS    %f ${dns}"
  print -P "  %F{white}Rekey  %f in $(( rekey / 60 ))m"
}

function tifr-off() {
  local raw summary
  raw=$(swanctl --list-sas --ike tifr --raw 2>&1) || {
    _tifr_error "$raw"
    return 1
  }
  if [[ "$raw" != *local-host=* ]]; then
    print -P '%F{yellow}○%f tifr VPN: already disconnected'
    return 0
  fi
  summary=$(_tifr_summary)

  local out
  if out=$(swanctl --terminate --ike tifr 2>&1); then
    print -P "%F{yellow}○%f tifr VPN: %B%F{yellow}Disconnected%b%f"
    [[ -n "$summary" ]] && print -P "  %F{cyan}Session%f ${summary}"
    notify-send -a tifrvpn "tifr VPN" "Disconnected" 2>/dev/null || true
    return 0
  else
    print -P "%F{red}✗%f tifr VPN: failed to disconnect"
    _tifr_error "$out"
    return 1
  fi
}

function _tifr_summary() {
  local raw established bytes_in bytes_out
  raw=$(swanctl --list-sas --ike tifr --raw 2>/dev/null)
  [[ "$raw" != *"local-host="* ]] && return

  established=$(grep -oP 'established=\K[0-9]+' <<< "$raw" | head -1)
  bytes_in=$(grep -oP 'bytes-in=\K[0-9]+' <<< "$raw" | awk '{s+=$1} END{print s+0}')
  bytes_out=$(grep -oP 'bytes-out=\K[0-9]+' <<< "$raw" | awk '{s+=$1} END{print s+0}')

  local mins=$(( established / 60 ))
  local secs=$(( established % 60 ))
  local human_in human_out
  human_in=$(numfmt --to=iec --suffix=B "$bytes_in" 2>/dev/null)
  human_out=$(numfmt --to=iec --suffix=B "$bytes_out" 2>/dev/null)

  print -nP "${mins}m ${secs}s, ↓ %F{green}${human_in}%f  ↑ %F{red}${human_out}%f"
}

function tifr-status() {
  local raw
  raw=$(swanctl --list-sas --ike tifr --raw 2>&1) || {
    print -P '%F{red}✗%f tifr VPN: cannot query daemon; run tifrvpn --setup'
    _tifr_error "$raw"
    return 1
  }

  if ! _tifr_is_connected "$raw"; then
    print -P "%F{red}○%f tifr VPN: %B%F{red}Disconnected%b%f"
    return 1
  fi

  local state local_id local_host local_vip remote_host established rekey encr keysize integ dh bytes_in bytes_out
  state=$(grep -oP 'state=\K\w+' <<< "$raw" | head -1)
  local_id=$(grep -oP 'local-id=\K\S+' <<< "$raw" | head -1)
  local_host=$(grep -oP 'local-host=\K[0-9.]+' <<< "$raw" | head -1)
  local_vip=$(grep -oP 'local-vips=\[\K[0-9.]+' <<< "$raw" | head -1)
  remote_host=$(grep -oP 'remote-host=\K[0-9.]+' <<< "$raw" | head -1)
  established=$(grep -oP 'established=\K[0-9]+' <<< "$raw" | head -1)
  rekey=$(grep -oP 'rekey-time=\K[0-9]+' <<< "$raw" | head -1)
  encr=$(grep -oP 'encr-alg=\K\w+' <<< "$raw" | head -1)
  keysize=$(grep -oP 'encr-keysize=\K[0-9]+' <<< "$raw" | head -1)
  integ=$(grep -oP 'integ-alg=\K\w+' <<< "$raw" | head -1)
  dh=$(grep -oP 'dh-group=\K\w+' <<< "$raw" | head -1)
  bytes_in=$(grep -oP 'bytes-in=\K[0-9]+' <<< "$raw" | awk '{s+=$1} END{print s+0}')
  bytes_out=$(grep -oP 'bytes-out=\K[0-9]+' <<< "$raw" | awk '{s+=$1} END{print s+0}')

  local human_in human_out
  human_in=$(numfmt --to=iec --suffix=B "$bytes_in" 2>/dev/null)
  human_out=$(numfmt --to=iec --suffix=B "$bytes_out" 2>/dev/null)

  local mins=$(( established / 60 ))
  local secs=$(( established % 60 ))

  print -P "%F{green}●%f tifr VPN: %B%F{green}Connected%b%f (${state})"
  print -P "  %F{magenta}User   %f ${local_id}"
  print -P "  %F{blue}Local  %f ${local_host}  →  VIP %B${local_vip}%b"
  print -P "  %F{blue}Gateway%f ${remote_host}"
  print -P "  %F{cyan}Cipher %f ${encr}-${keysize} / ${integ} / ${dh}"
  print -P "  %F{white}Rekey  %f in $(( rekey / 60 ))m"
  print -P "  %F{yellow}Uptime %f ${mins}m ${secs}s"
  print -P "  %F{cyan}Traffic%f ↓ %F{green}${human_in}%f  ↑ %F{red}${human_out}%f"
}

function tifrvpn() {
  if (( $# > 1 )) && [[ "$1" != --setup ]]; then
    print -u2 -- 'Usage: tifrvpn [-c|-d|-s|--setup|--help]'
    return 2
  fi
  case "$1" in
    -s) tifr-status; return ;;
    -c) tifr-on; return ;;
    -d) tifr-off; return ;;
    --setup) shift; tifr-setup "$@"; return ;;
    -h|--help)
      print -r -- 'Usage: tifrvpn [-c|-d|-s|--setup] (no option: toggle)'
      print -r -- 'Setup or repair: tifrvpn --setup'
      print -r -- 'Regenerate credentials: tifrvpn --setup --configure /path/to/NcpImport.log --username YOUR_TIFR_USERNAME'
      return 0 ;;
    '') ;;
    *) print -u2 -- 'Usage: tifrvpn [-c|-d|-s|--setup|--help]'; return 2 ;;
  esac
  _tifr_ensure_daemon || return 1
  local raw
  raw=$(swanctl --list-sas --ike tifr --raw 2>&1) || {
    _tifr_error "$raw"
    return 1
  }
  if _tifr_is_connected "$raw"; then
    tifr-off
  else
    tifr-on
  fi
}
