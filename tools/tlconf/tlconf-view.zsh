#!/bin/zsh
# Responsive shell-only viewer. Opens immediately and refreshes asynchronously.
emulate -LR zsh
setopt PIPE_FAIL
umask 077

preview_layout() {
  local width=${FZF_COLUMNS:-${COLUMNS:-80}}
  local height=${FZF_LINES:-${LINES:-24}}
  if ((width >= 110)); then
    print -r -- "right,$((width - 44)),border-rounded"
  else
    local detail_height=$((height - 17))
    ((detail_height < 5)) && detail_height=5
    print -r -- "down,${detail_height},border-rounded"
  fi
}

make_menu() {
  awk '
        /^=/ {
            section++; name=$0
            sub(/^=+[[:space:]]*/,"",name); sub(/[[:space:]]*=+$/,"",name)
            if(name ~ /version information/) name="Installation"
            if(name ~ /executables found/) name="Executables & PATH"
            if(name ~ /active config/) name="Configuration files"
            if(name ~ /font map/) name="Font maps"
            if(name == "kpathsea variables") name="Kpathsea variables"
            if(name ~ /from environment only/) name="Environment overrides"
            names[section]=name; next
        }
        section && NF {count[section]++}
        END {
            printf "0\t\033[34m◇\033[0m  %-21s \033[90mall\033[0m\n","Overview"
            for(i=1;i<=section;i++)
                printf "%d\t\033[36m%02d\033[0m %-21s \033[90m%2d\033[0m\n",i,i,names[i],count[i]
        }
    ' "$TLCONF_REPORT"
}

case ${1:-} in
--layout)
  print -r -- "change-preview-window($(preview_layout))+refresh-preview"
  exit 0
  ;;
--refresh)
  if command tlmgr conf >"$TLCONF_REPORT.next" 2>"$TLCONF_SESSION/error" &&
    [[ -s "$TLCONF_REPORT.next" ]]; then
    command mv -- "$TLCONF_REPORT.next" "$TLCONF_REPORT"
    print -r -- 'Live report · Ctrl+R refresh' >"$TLCONF_STATUS"
    if command cp -- "$TLCONF_REPORT" "$TLCONF_CACHE.$$.next"; then
      command mv -- "$TLCONF_CACHE.$$.next" "$TLCONF_CACHE"
    fi
  else
    print -r -- 'Refresh failed · Ctrl+R retry' >"$TLCONF_STATUS"
  fi
  if [[ -s "$TLCONF_REPORT" ]]; then
    make_menu >"$TLCONF_SESSION/refreshed-menu"
  else
    command cp -- "$TLCONF_SESSION/menu" "$TLCONF_SESSION/refreshed-menu"
  fi
  print -r -- 'reload-sync(cat "$TLCONF_SESSION/refreshed-menu")+refresh-preview+transform-header(cat "$TLCONF_STATUS")'
  exit 0
  ;;
esac

for tool in tlmgr awk fzf tput mktemp cksum; do
  if ((! $+commands[$tool])); then
    print -u2 -- "Missing command: $tool"
    exit 1
  fi
done

export TLCONF_VIEWER=${0:A}
export TLCONF_FORMATTER="${TLCONF_VIEWER:h}/tlconf-view.awk"
[[ -r $TLCONF_FORMATTER ]] || {
  print -u2 -- "Formatter not found: $TLCONF_FORMATTER"
  exit 1
}
export TLCONF_SESSION=$(mktemp -d "${TMPDIR:-/tmp}/tlconf-view.XXXXXXXX")
[[ -d $TLCONF_SESSION ]] || exit 1
cleanup() {
  local file
  for file in "$TLCONF_SESSION"/*(N.); do
    command rm -- "$file"
  done
  command rmdir -- "$TLCONF_SESSION"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM HUP
export TLCONF_REPORT="$TLCONF_SESSION/report"
export TLCONF_STATUS="$TLCONF_SESSION/status"

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/tlconf-view"
command mkdir -p -- "$cache_dir" || exit 1
cache_key=$(print -r -- "$PATH" "${TEXMFHOME-}" "${TEXMFCNF-}" "${TEXMFCONFIG-}" "${TEXMFVAR-}" | cksum)
cache_key=${cache_key%% *}
export TLCONF_CACHE="$cache_dir/$cache_key.conf"
if [[ -s $TLCONF_CACHE ]]; then
  command cp -- "$TLCONF_CACHE" "$TLCONF_REPORT" || exit 1
  make_menu >"$TLCONF_SESSION/menu"
  print -r -- 'Cached report · refreshing…' >"$TLCONF_STATUS"
else
  print -r -- 'Reading TeX Live configuration…' >"$TLCONF_STATUS"
  print -r -- $'0\t◇  Overview\n1\t01 Installation\n2\t02 Executables & PATH\n3\t03 Configuration files\n4\t04 Font maps\n5\t05 Kpathsea variables\n6\t06 Environment overrides' >"$TLCONF_SESSION/menu"
fi

COLUMNS=$(tput cols)
LINES=$(tput lines)
initial_layout=$(preview_layout)
initial_status=$(<"$TLCONF_STATUS")
export FZF_DEFAULT_OPTS='' FZF_DEFAULT_OPTS_FILE=''
command fzf \
  --ansi --sync --no-sort --layout=reverse --height=100% \
  --style=default --border=rounded --padding=0,1 \
  --list-border=rounded --input-border=rounded \
  --header-border=none --footer-border=none \
  --border-label=' TeX Live · Configuration explorer ' \
  --list-label=' Sections ' --input-label=' Filter ' \
  --preview-label=' Details ' \
  --header="$initial_status" \
  --footer=$'Ctrl+D/U scroll preview\nCtrl+R refresh · Enter zoom\nEsc close' \
  --prompt='❯ ' --pointer='▌' --highlight-line \
  --ghost='Find a section…' --info=inline-right \
  --delimiter=$'\t' --with-nth=2.. \
  --with-shell='/bin/sh -c' \
  --color='dark,fg:7,bg:-1,hl:6,fg+:-1,bg+:0,hl+:6' \
  --color='border:8,label:4,header:7,footer:8,info:6' \
  --color='pointer:6,prompt:4,spinner:6,gutter:-1,marker:5' \
  --preview='if test -s "$TLCONF_REPORT"; then awk -v selected={1} -v cols="$FZF_PREVIEW_COLUMNS" -f "$TLCONF_FORMATTER" "$TLCONF_REPORT"; else printf "\n  Reading TeX Live configuration…\n  The report will appear automatically.\n"; fi' \
  --preview-window="$initial_layout" \
  --bind='start:bg-transform(/bin/zsh -f "$TLCONF_VIEWER" --refresh)' \
  --bind='ctrl-r:bg-cancel+change-header(Refreshing report…)+bg-transform(/bin/zsh -f "$TLCONF_VIEWER" --refresh)' \
  --bind='load:refresh-preview+transform-header(cat "$TLCONF_STATUS")' \
  --bind='tab:down,btab:up,ctrl-d:preview-page-down,ctrl-u:preview-page-up' \
  --bind='enter:change-preview-window(right,99%|)' \
  --bind='resize:transform(/bin/zsh -f "$TLCONF_VIEWER" --layout)' \
  <"$TLCONF_SESSION/menu" >/dev/null
viewer_result=$?
((viewer_result == 130 || viewer_result == 1)) && exit 0
exit $viewer_result
