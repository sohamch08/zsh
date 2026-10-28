function _tifr_ensure_daemon() {
  [[ -S /run/strongswan/charon.vici ]] && return 0

  print -P "%F{yellow}⋯%f tifr VPN: starting strongswan service"
  sudo systemctl start strongswan || {
    print -P "%F{red}✗%f tifr VPN: failed to start strongswan service"
    return 1
  }

  local i
  for i in {1..20}; do
    [[ -r /run/strongswan/charon.vici ]] && return 0
    sleep 0.25
  done

  print -P "%F{red}✗%f tifr VPN: strongswan service did not come up in time"
  return 1
}

function tifr-on() {
  _tifr_ensure_daemon || return 1

  local out
  if out=$(swanctl --initiate --child tifr-net 2>&1); then
    _tifr_connect_info "$out"
    notify-send -a tifrvpn "tifr VPN" "Connected" 2>/dev/null
  else
    print -P "%F{red}✗%f tifr VPN: failed to connect"
    grep -E 'failed|error' -i <<< "$out" | tail -3
    return 1
  fi
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
  local summary
  summary=$(_tifr_summary)

  local out
  if out=$(swanctl --terminate --ike tifr 2>&1); then
    print -P "%F{yellow}○%f tifr VPN: %B%F{yellow}Disconnected%b%f"
    [[ -n "$summary" ]] && print -P "  %F{cyan}Session%f ${summary}"
    notify-send -a tifrvpn "tifr VPN" "Disconnected" 2>/dev/null
  else
    print -P "%F{red}✗%f tifr VPN: failed to disconnect"
    grep -E 'failed|error' -i <<< "$out" | tail -3
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
  raw=$(swanctl --list-sas --ike tifr --raw 2>/dev/null)

  if [[ -z "$raw" || "$raw" != *"local-host="* ]]; then
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
  case "$1" in
    -s) tifr-status; return ;;
    -c) tifr-on; return ;;
    -d) tifr-off; return ;;
  esac
  if swanctl --list-sas --ike tifr 2>/dev/null | grep -q .; then
    tifr-off
  else
    tifr-on
  fi
}
