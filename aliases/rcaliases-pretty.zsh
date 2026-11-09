# Formatted rclone helpers. User documentation lives in docs/rclone/.
typeset -g _rc_pretty_formatter="$ZDOTDIR/tools/rclone/rclone-format.py"
typeset -g _rc_help_dir="$ZDOTDIR/docs/rclone"

# Clear previous aliases before defining functions; safe to source repeatedly.
unalias rc rcremotes rcconfig rcedit rclog rclog-clear \
  rcl rcd rct rcls rctree rcinfo rcbrowse rcpick rcmount rcumount \
  rccopy rcto rcplan rcmirror rcpull rcpush rcsync-down rcsync-up rcdry-down rcdry-up \
  rcstatus rcremote-only rclocal-only rcdiff rcgit rchelp rcsize rcspace 2>/dev/null || true
unfunction rcsize rcspace 2>/dev/null || true

# Raw rclone keeps its native subcommands and help.
alias rc='rclone'

# Only explicit help flags before -- are intercepted.
_rc_help_requested() {
  local argument
  for argument in "$@"; do
    case $argument in
    --) return 1 ;;
    -h | --help) return 0 ;;
    esac
  done
  return 1
}

# Named boundaries stay valid when documentation paragraphs are added or removed.
_rc_help_section() {
  local topic="$1" doc_file="$2" line
  local -i found=0
  while IFS= read -r line || [[ -n $line ]]; do
    if [[ $line == '@@ '* ]]; then
      ((found)) && return 0
      [[ $line == "@@ $topic" ]] && found=1
    elif ((found)); then
      print -r -- "$line"
    fi
  done <"$doc_file"
  if ((! found)); then
    print -u2 -- "No help section for '$topic' in $doc_file."
    return 2
  fi
  return 0
}

# Apply the palette initialized by colored-man-pages; define no colors here.
_rc_render_help() {
  emulate -L zsh
  if [[ ! -t 1 || ${TERM:-dumb} == dumb || ${+NO_COLOR} == 1 ||
        ${(t)less_termcap} != association* ]]; then
    print -r -- "$1"
    return
  fi

  local heading=${less_termcap[md]-} accent=${less_termcap[us]-}
  local heading_end=${less_termcap[me]-} accent_end=${less_termcap[ue]-}

  local line remaining rendered
  local token_pattern='(^|[^[:alnum:]_-])(--?[[:alpha:]][[:alnum:]-]*|rc[[:alnum:]-]*)([^[:alnum:]_-]|$)'
  local -a match
  local -i first=1 MBEGIN MEND
  for line in "${(@f)1}"; do
    if (( first )) || [[ $line != [[:space:]]* && $line == *: ]]; then
      print -r -- "${heading}${line}${heading_end}"
      first=0
      continue
    fi

    rendered=''
    remaining=$line
    while [[ $remaining =~ $token_pattern ]]; do
      rendered+="${remaining[1,MBEGIN-1]}${match[1]}${accent}${match[2]}${accent_end}${match[3]}"
      remaining=${remaining[MEND+1,-1]}
    done
    print -r -- "${rendered}${remaining}"
  done
}

_rc_show_help() {
  local topic="${1:-index}" group
  case $topic in
  index) group=index ;;
  rc | rcremotes | rcconfig | rcedit | rclog | rclog-clear | rchelp) group=general ;;
  rcl | rcd | rcls | rct | rctree) group=listings ;;
  rcinfo | rcbrowse | rcpick) group=storage ;;
  rcmount | rcumount) group=mounts ;;
  rccopy | rcto | rcplan | rcmirror | rcpull | rcpush | rcsync-down | rcsync-up | rcdry-down | rcdry-up)
    group=transfers
    ;;
  rcstatus | rcremote-only | rclocal-only | rcdiff | rcgit) group=comparisons ;;
  *)
    print -u2 -- "Unknown rclone help topic: $topic. Run rchelp for the command list."
    return 2
    ;;
  esac
  local doc_file="$_rc_help_dir/$group.txt" help_text
  if [[ ! -f $doc_file || ! -r $doc_file ]]; then
    print -u2 -- "No help found for '$topic' ($doc_file). Run rchelp for the command list."
    return 2
  fi
  if [[ $topic == index ]]; then
    help_text=$(<"$doc_file")
  else
    help_text=$(_rc_help_section "$topic" "$doc_file") || return
  fi
  _rc_render_help "$help_text"
}

# Help is handled before the operation or its argument validation can run.
_rc_run() {
  local topic="$1"
  shift
  if _rc_help_requested "$@"; then
    _rc_show_help "$topic"
  else
    "$@"
  fi
}

# Remote names, local paths, and shared command execution.

_rc_remote_path() {
  local target="${1-}"
  if [[ -z $target || $target == -* || $target == /* ||
    $target == ./* || $target == ../* ]]; then
    print -u2 -- 'Expected REMOTE, REMOTE:, or REMOTE:PATH.'
    return 2
  fi

  if [[ $target == *:* ]]; then
    if [[ -z ${target%%:*} || ${target%%:*} == */* ]]; then
      print -u2 -- 'Expected a configured remote name before the colon.'
      return 2
    fi
    print -r -- "$target"
  elif [[ $target == */* ]]; then
    print -u2 -- 'Use REMOTE:PATH for a folder inside a remote.'
    return 2
  else
    print -r -- "${target}:"
  fi
}

_rc_auto_path() {
  local target="$1" configured="$2" remote
  if [[ $target != *[:/]* ]]; then
    for remote in "${(@f)configured}"; do
      if [[ $remote == "${target}:" ]]; then
        print -r -- "$remote"
        return 0
      fi
    done
  fi
  print -r -- "$target"
}

_rc_remote_command() {
  local subcommand="$1"
  shift
  if (($# < 1)); then
    print -u2 -- "Usage: remote helper REMOTE[:PATH] [OPTIONS...] ($subcommand)"
    return 2
  fi
  local target
  target=$(_rc_remote_path "$1") || return
  shift
  command rclone "$subcommand" "$@" -- "$target"
}

_rc_pair_command() {
  local operation="$1" direction="$2"
  shift 2
  if (($# < 2)) || [[ -z $1 || -z $2 || $1 == -* || $2 == -* ]]; then
    print -u2 -- 'Usage: transfer/status helper SOURCE DESTINATION [OPTIONS...]'
    return 2
  fi

  local source_path="$1" destination_path="$2" configured
  local -a defaults
  shift 2

  case $direction in
  down) source_path=$(_rc_remote_path "$source_path") || return ;;
  up) destination_path=$(_rc_remote_path "$destination_path") || return ;;
  auto)
    configured=$(command rclone listremotes) || return
    source_path=$(_rc_auto_path "$source_path" "$configured") || return
    destination_path=$(_rc_auto_path "$destination_path" "$configured") || return
    ;;
  esac

  case $operation in
  copy | copyto | sync) defaults=(--progress) ;;
  copy-preview)
    operation=copy
    defaults=(--progress --dry-run)
    ;;
  sync-preview)
    operation=sync
    defaults=(--progress --dry-run)
    ;;
  esac

  command rclone "$operation" "${defaults[@]}" "$@" -- \
    "$source_path" "$destination_path"
}

# Metadata-only formatted listings; Python starts only on a listing request.

_rc_pretty() {
  emulate -L zsh
  setopt PIPE_FAIL

  local mode="$1"
  shift
  if (($# < 1)); then
    print -u2 -- 'Usage: listing-helper REMOTE[:PATH] [OPTIONS...]'
    return 2
  fi

  if [[ ! -r $_rc_pretty_formatter ]]; then
    print -u2 -- "Missing formatter: $_rc_pretty_formatter"
    return 1
  fi
  if ((! $+commands[python3])); then
    print -u2 -- 'Formatted listings require python3.'
    return 1
  fi

  local remote
  remote=$(_rc_remote_path "$1") || return
  shift
  local -a defaults options metadata_options formatter_options
  metadata_options=(--no-mimetype --no-modtime)
  case $mode in
  list) defaults=() ;;
  dirs) defaults=(--dirs-only) ;;
  long)
    defaults=()
    metadata_options=(--no-mimetype)
    ;;
  tree) defaults=(--recursive) ;;
  esac

  while (($#)); do
    case $1 in
    --level)
      if (($# < 2)); then
        print -u2 -- '--level needs a depth'
        return 2
      fi
      options+=(--max-depth "$2")
      shift 2
      ;;
    --level=*)
      options+=("--max-depth=${1#*=}")
      shift
      ;;
    --size | -s | --no-size)
      if [[ $mode != tree ]]; then
        print -u2 -- 'Use --size/--no-size with rct or rctree; rcls always shows sizes.'
        return 2
      fi
      if [[ $1 == --no-size ]]; then
        formatter_options=()
      else
        formatter_options=(--size)
      fi
      shift
      ;;
    --stat)
      print -u2 -- 'Formatted listings do not support --stat; use rc lsjson directly.'
      return 2
      ;;
    *)
      options+=("$1")
      shift
      ;;
    esac
  done

  command rclone lsjson "${metadata_options[@]}" \
    "${defaults[@]}" "${options[@]}" -- "$remote" |
    command python3 "$_rc_pretty_formatter" "$mode" "${formatter_options[@]}"
}

_rc_info() {
  if (($# < 1)); then
    print -u2 -- 'Usage: rcinfo REMOTE[:PATH] [OPTIONS...]'
    return 2
  fi
  local remote root_remote
  local -i result=0
  remote=$(_rc_remote_path "$1") || return
  root_remote="${remote%%:*}:"
  shift

  print -r -- "Contents: $remote"
  command rclone size "$@" -- "$remote" || result=$?
  print
  print -r -- "Storage quota: $root_remote"
  command rclone about "$@" -- "$root_remote" || result=$?
  return "$result"
}

_rc_pick() {
  emulate -L zsh
  setopt PIPE_FAIL
  local remote
  remote=$(
    command rclone listremotes |
      command fzf --prompt='Choose remote > '
  ) || return
  [[ -n $remote ]] || return
  rcbrowse "$remote"
}

_rc_mount_name() {
  local target
  target=$(_rc_remote_path "${1-}") || return
  if [[ $target != *: || ${target%:} == *[:/]* ]]; then
    print -u2 -- 'Mount helpers require a whole remote: NAME or NAME:.'
    return 2
  fi
  print -r -- "${target%:}"
}

_rc_mount() {
  if (($# < 1)); then
    print -u2 -- 'Usage: rcmount REMOTE [OPTIONS...]'
    return 2
  fi
  local remote
  remote=$(_rc_mount_name "$1") || return
  shift
  local mount="$HOME/${remote}-rclone"

  if command mountpoint -q -- "$mount"; then
    print -r -- "Already mounted at $mount"
    return 0
  fi

  command mkdir -p -- "$mount" || return
  command rclone mount --daemon --vfs-cache-mode full "$@" -- \
    "${remote}:" "$mount" || return
  print -r -- "Mounted ${remote}: at $mount"
}

_rc_umount() {
  if (($# != 1)); then
    print -u2 -- 'Usage: rcumount REMOTE'
    return 2
  fi
  local remote
  remote=$(_rc_mount_name "$1") || return
  local mount="$HOME/${remote}-rclone"

  if command mountpoint -q -- "$mount"; then
    command fusermount -u -- "$mount" || return
    print -r -- "Unmounted ${remote}:"
  else
    print -r -- "Already unmounted: ${remote}:"
  fi

  if [[ ! -e $mount && ! -L $mount ]]; then
    print -r -- "No mount folder to remove: $mount"
    return 0
  fi

  command rmdir -- "$mount" || return
  print -r -- "Removed empty mount folder: $mount"
}

_rc_status() {
  if (($# < 2)); then
    print -u2 -- 'Usage: rcstatus REMOTE[:PATH] LOCAL_PATH [OPTIONS...]'
    return 2
  fi
  print -r -- '=  identical'
  print -r -- '-  only on local'
  print -r -- '+  only on remote'
  print -r -- '*  different on both'
  print -r -- '!  error checking the file'
  print -r -- '──────────────────────────────'
  _rc_pair_command check down "$@" --combined -
}

_rc_git() {
  if (($# < 2)); then
    print -u2 -- 'Usage: rcgit REMOTE[:PATH] LOCAL_PATH [OPTIONS...]'
    return 2
  fi
  local remote local_path="$2"
  local -i result=0
  remote=$(_rc_remote_path "$1") || return
  shift 2

  print
  print -r -- "📡 Remote: $remote"
  print -r -- "💻 Local:  $local_path"
  print -r -- '──────────────────────────────────────'
  print
  print -r -- '🔼 Local ahead (only on local):'
  _rc_pair_command check down "$remote" "$local_path" "$@" \
    --missing-on-src - || result=$?
  print
  print -r -- '🔽 Remote ahead (only on remote):'
  _rc_pair_command check down "$remote" "$local_path" "$@" \
    --missing-on-dst - || result=$?
  print
  print -r -- '📝 Different on both:'
  _rc_pair_command check down "$remote" "$local_path" "$@" \
    --differ - || result=$?
  print -r -- '──────────────────────────────────────'
  return "$result"
}

_rc_config() {
  command sed -E 's/^([[:space:]]*(token|root_folder_id)[[:space:]]*=[[:space:]]*).*/\1██████████████████████████████/' \
    "$HOME/.config/rclone/rclone.conf" | command bat --language=ini "$@"
}

_rc_log_clear() {
  if (($#)); then
    print -u2 -- 'Usage: rclog-clear'
    return 2
  fi
  : >"$HOME/.config/rclone/rclone.log"
}

# Public commands share the same help guard and retain their operation arguments.
rcremotes() { _rc_run rcremotes command rclone listremotes "$@"; }
rcconfig() { _rc_run rcconfig _rc_config "$@"; }
rcedit() { _rc_run rcedit command nvim "$HOME/.config/rclone/rclone.conf" "$@"; }
rclog() { _rc_run rclog command tail -f "$HOME/.config/rclone/rclone.log" "$@"; }
rclog-clear() { _rc_run rclog-clear _rc_log_clear "$@"; }

rcl() { _rc_run rcl _rc_pretty list "$@"; }
rcd() { _rc_run rcd _rc_pretty dirs "$@"; }
rct() { _rc_run rct _rc_pretty tree "${1-}" --max-depth 2 "${@:2}"; }
rcls() { _rc_run rcls _rc_pretty long "$@"; }
rctree() { _rc_run rctree _rc_pretty tree "$@"; }
rcinfo() { _rc_run rcinfo _rc_info "$@"; }
rcbrowse() { _rc_run rcbrowse _rc_remote_command ncdu "$@"; }
rcpick() { _rc_run rcpick _rc_pick "$@"; }
rcmount() { _rc_run rcmount _rc_mount "$@"; }
rcumount() { _rc_run rcumount _rc_umount "$@"; }

rccopy() { _rc_run rccopy _rc_pair_command copy auto "$@"; }
rcto() { _rc_run rcto _rc_pair_command copyto auto "$@"; }
rcplan() { _rc_run rcplan _rc_pair_command sync-preview auto "$@"; }
rcmirror() { _rc_run rcmirror _rc_pair_command sync auto "$@"; }
rcpull() { _rc_run rcpull _rc_pair_command copy down "$@"; }
rcpush() { _rc_run rcpush _rc_pair_command copy up "$@"; }
rcsync-down() { _rc_run rcsync-down _rc_pair_command sync down "$@"; }
rcsync-up() { _rc_run rcsync-up _rc_pair_command sync up "$@"; }
rcdry-down() { _rc_run rcdry-down _rc_pair_command copy-preview down "$@"; }
rcdry-up() { _rc_run rcdry-up _rc_pair_command copy-preview up "$@"; }

rcstatus() { _rc_run rcstatus _rc_status "$@"; }
rcremote-only() { _rc_run rcremote-only _rc_pair_command check down "$@" --missing-on-dst -; }
rclocal-only() { _rc_run rclocal-only _rc_pair_command check down "$@" --missing-on-src -; }
rcdiff() { _rc_run rcdiff _rc_pair_command check down "$@" --differ -; }
rcgit() { _rc_run rcgit _rc_git "$@"; }

rchelp() {
  if _rc_help_requested "$@"; then
    _rc_show_help rchelp
  elif (($# > 1)); then
    print -u2 -- 'Usage: rchelp [COMMAND]'
    return 2
  else
    _rc_show_help "${1:-index}"
  fi
}
