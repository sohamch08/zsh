# ─── RCLONE GENERAL ALIASES ───────────────────────────────────────────────────
# Clear old aliases before defining functions, including during a reload.
unalias rcl rcd rct rcsize rcspace rcbrowse rccopy rcto rcplan rcmirror 2>/dev/null

# rc SUBCOMMAND [ARGUMENTS...]
# Short form of rclone, e.g. `rc config` opens interactive remote configuration.
# Uses native rclone syntax: unlike the helpers below, remote paths need a colon.
alias rc='rclone'

# rcremotes: print every configured remote name, such as visa: and gdrive:.
alias rcremotes='rclone listremotes'

# rcconfig: display config with bat, masking token and root_folder_id values.
# Other configuration fields are displayed as stored; this is not full redaction.
alias rcconfig='sed -E "s/^([[:space:]]*(token|root_folder_id)[[:space:]]*=[[:space:]]*).*/\1██████████████████████████████/" ~/.config/rclone/rclone.conf | bat --language=ini'

# rcedit: open the rclone configuration file in nvim for editing.
alias rcedit='nvim ~/.config/rclone/rclone.conf'

# rclog: display the last lines of ~/.config/rclone/rclone.log and follow updates.
# Press Ctrl+C to stop following. This command does not enable logging itself.
alias rclog='tail -f ~/.config/rclone/rclone.log'

# rclog-clear: empty ~/.config/rclone/rclone.log, keeping the file itself.
# Creates an empty log file if it is missing and its parent directory exists.
alias rclog-clear='> ~/.config/rclone/rclone.log'

# ─── PATH NORMALIZATION ───────────────────────────────────────────────────────
# Functions beginning with _rc_ are internal helpers used by the public commands.
# The commands below accept NAME or NAME: for a remote root, and NAME:PATH for
# a remote folder. Quote paths with spaces. Put extra options after the paths.
# Remote-only arguments accept NAME, NAME:, and NAME:PATH.
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

# Generic transfers distinguish bare configured remote names from local paths.
# Explicit paths (./name, /path, NAME:PATH) are passed through unchanged.
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

# First two user arguments are always SOURCE DESTINATION; options follow them.
# Direction identifies the remote operand; auto checks configured remote names.
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

# ─── BROWSE AND INSPECT ────────────────────────────────────────────────────────
# rcl REMOTE[:PATH] [OPTIONS...]
# List the immediate files and folders, without sizes or recursive traversal.
# Example: rcl "visa:Visa Application"
rcl() { _rc_remote_command lsf "$@"; }

# rcd REMOTE[:PATH] [OPTIONS...]
# List only the immediate folders. It does not change your working directory.
# Example: rcd gdrive
rcd() { _rc_remote_command lsf "${1-}" --dirs-only "${@:2}"; }

# rct REMOTE[:PATH] [OPTIONS...]
# Show a tree two levels deep, with folders first. Override depth with --level.
# Example: rct gdrive:Papers --level 4
rct() { _rc_remote_command tree "${1-}" --level 2 --dirsfirst "${@:2}"; }

# rcls REMOTE[:PATH] [OPTIONS...]
# Recursively list files and their sizes; directory entries are not included.
# Example: rcls visa --max-depth 1
rcls() { _rc_remote_command ls "${1-}" --human-readable "${@:2}"; }

# rctree REMOTE[:PATH] [OPTIONS...]
# Show the full tree unless you supply --level. Does not mount the remote.
# Example: rctree gdrive:Papers --level 3
rctree() { _rc_remote_command tree "$@"; }

# rcsize REMOTE[:PATH] [OPTIONS...]
# Count files and add up their sizes recursively. Does not download their contents.
# Example: rcsize "visa:Visa Application"
rcsize() { _rc_remote_command size "$@"; }

# rcspace REMOTE [OPTIONS...]
# Show storage quota, used space, and free space when supported by the provider.
# This describes account/remote capacity; use rcsize for a particular folder.
# Example: rcspace gdrive
rcspace() { _rc_remote_command about "$@"; }

# rcbrowse REMOTE[:PATH] [OPTIONS...]
# Open rclone's interactive storage explorer, which scans file sizes.
# Arrows or hjkl navigate, q quits, and d can delete files or directories.
# Example: rcbrowse gdrive:Papers
rcbrowse() { _rc_remote_command ncdu "$@"; }

# rcpick
# Choose a configured remote with FZF, then open the same explorer as rcbrowse.
# Enter selects a remote; cancel the picker to leave without opening one.
rcpick() {
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

# ─── MOUNT AND UNMOUNT ─────────────────────────────────────────────────────────
# Whole remotes use the same mount directory with or without a trailing colon.
_rc_mount_name() {
  local target
  target=$(_rc_remote_path "${1-}") || return
  if [[ $target != *: || ${target%:} == *[:/]* ]]; then
    print -u2 -- 'Mount helpers require a whole remote: NAME or NAME:.'
    return 2
  fi
  print -r -- "${target%:}"
}

# rcmount REMOTE [OPTIONS...]
# Mount a whole remote at ~/<name>-rclone, creating the local folder if needed.
# Runs in the background with full VFS caching, so applications can use the files.
# Reuses an existing mount folder; if it is already mounted, reports that and stops.
# Example: rcmount visa:  ->  ~/visa-rclone
rcmount() {
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

# rcumount REMOTE
# Disconnect ~/<name>-rclone if mounted, then remove the local folder if empty.
# An already-unmounted remote or missing folder is handled without an error.
# If the folder contains local files, rmdir leaves it intact and returns an error.
# Example: rcumount visa  (visa: works too)
rcumount() {
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

# ─── TRANSFERS AND PREVIEWS ────────────────────────────────────────────────────
# Generic transfers normalize either operand if it is a bare configured remote.
# Use ./visa when referring to a local folder named like the visa remote.
# Copy/sync directory operations transfer contents into the destination directory.

# rccopy SOURCE DESTINATION [OPTIONS...]
# Copy with progress: local -> remote, remote -> local, or remote -> remote.
# Can update existing files, but does not delete extra destination files.
# Example: rccopy ./papers gdrive:Papers --include '*.pdf'
rccopy() { _rc_pair_command copy auto "$@"; }

# rcto SOURCE DESTINATION [OPTIONS...]
# Copy a file to an exact destination filename, optionally renaming it there.
# Can replace an existing destination file; displays transfer progress.
# Example: rcto ./draft.pdf gdrive:Papers/final.pdf
rcto() { _rc_pair_command copyto auto "$@"; }

# rcplan SOURCE DESTINATION [OPTIONS...]
# Preview a sync, including copies, updates, and extra destination files to delete.
# Uses --dry-run: shows planned operations without performing them.
# Example: rcplan ./papers gdrive:Papers
rcplan() { _rc_pair_command sync-preview auto "$@"; }

# rcmirror SOURCE DESTINATION [OPTIONS...]
# Sync with progress so the destination matches the source, including deletions.
# Source and destination can each be local or remote. Preview with rcplan first.
# Example: rcmirror ./papers gdrive:Papers
rcmirror() { _rc_pair_command sync auto "$@"; }

# Directional helpers normalize only the remote operand, leaving local paths alone.
# rcpull REMOTE[:PATH] LOCAL_PATH [OPTIONS...]
# Copy remote contents to a local directory, keeping extra local files.
# Example: rcpull "visa:Visa Application" ~/Downloads/Visa
rcpull() { _rc_pair_command copy down "$@"; }

# rcpush LOCAL_PATH REMOTE[:PATH] [OPTIONS...]
# Copy local contents to a remote directory, keeping extra remote files.
# Example: rcpush ~/Documents gdrive:Documents
rcpush() { _rc_pair_command copy up "$@"; }

# rcsync-down REMOTE[:PATH] LOCAL_PATH [OPTIONS...]
# Make the local destination match the remote source, deleting extra local files.
# Example: rcsync-down gdrive:Papers ./papers --dry-run  (preview before syncing)
rcsync-down() { _rc_pair_command sync down "$@"; }

# rcsync-up LOCAL_PATH REMOTE[:PATH] [OPTIONS...]
# Make the remote destination match the local source, deleting extra remote files.
# Example: rcsync-up ./papers gdrive:Papers --dry-run  (preview before syncing)
rcsync-up() { _rc_pair_command sync up "$@"; }

# rcdry-down REMOTE[:PATH] LOCAL_PATH [OPTIONS...]
# Preview a remote -> local COPY without changing files. Does not plan deletions.
# Example: rcdry-down visa ~/Downloads/Visa
rcdry-down() { _rc_pair_command copy-preview down "$@"; }

# rcdry-up LOCAL_PATH REMOTE[:PATH] [OPTIONS...]
# Preview a local -> remote COPY without changing files. Does not plan deletions.
# Example: rcdry-up ~/Documents gdrive:Documents
rcdry-up() { _rc_pair_command copy-preview up "$@"; }

# ─── STATUS: REMOTE FIRST, LOCAL DIRECTORY SECOND ──────────────────────────────
# rcstatus REMOTE[:PATH] LOCAL_PATH [OPTIONS...]
# Compare files recursively by size and available hashes; changes neither side.
# Prints a legend and one combined report: = same, - local only, + remote only,
# * different, ! error. A nonzero exit code can indicate differences or errors.
# Example: rcstatus gdrive:Papers ./papers
rcstatus() {
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

# rcremote-only REMOTE[:PATH] LOCAL_PATH [OPTIONS...]
# Report files present on the remote but missing locally. Does not download them.
# Example: rcremote-only gdrive:Papers ./papers
rcremote-only() { _rc_pair_command check down "$@" --missing-on-dst -; }

# rclocal-only REMOTE[:PATH] LOCAL_PATH [OPTIONS...]
# Report files present locally but missing on the remote. Does not upload them.
# Example: rclocal-only gdrive:Papers ./papers
rclocal-only() { _rc_pair_command check down "$@" --missing-on-src -; }

# rcdiff REMOTE[:PATH] LOCAL_PATH [OPTIONS...]
# Report files present on both sides whose size or available hash differs.
# Reports paths, not a line-by-line text diff. Does not change either side.
# Example: rcdiff gdrive:Papers ./papers
rcdiff() { _rc_pair_command check down "$@" --differ -; }

# rcgit REMOTE[:PATH] LOCAL_PATH [OPTIONS...]
# Run three comparisons and show separate local-only, remote-only, and changed
# sections. Does not use Git or synchronize files; three checks may take time.
# Preserves a nonzero result when any comparison reports differences or errors.
# Example: rcgit "visa:Visa Application" ~/local
rcgit() {
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

# ─── HELP ──────────────────────────────────────────────────────────────────────
# rchelp
# Display the terminal command reference and examples using bat.
# Includes remote-name rules, mount locations, copy vs sync, and status symbols.
rchelp() {
  bat --language=bash --style=plain <<'EOF'
# ── REMOTE NAMES AND PATHS ─────────────────────────────────────────────────────
# Every remote helper accepts visa OR visa: (likewise gdrive, gdrive:, etc.).
# Folder paths keep the colon: "visa:Visa Application" or gdrive:Papers.
# Quote paths containing spaces. Put additional options AFTER the paths.
# Mount/unmount take whole remote names; browsing/transfers also accept subpaths.
# rc is raw rclone: it retains rclone's original syntax.

# ── GENERAL ───────────────────────────────────────────────────────────────────
rchelp                                      # Show this help
rcremotes                                   # List configured remotes
rc config                                   # Interactive rclone configuration
rcconfig                                    # Show config, masking token and root_folder_id
rcedit                                      # Edit config in nvim
rclog                                       # Follow the configured log file
rclog-clear                                 # Empty that log file

# ── BROWSE AND INSPECT ─────────────────────────────────────────────────────────
rcl visa                                    # List immediate files and folders
rcd visa:                                   # List immediate folders only
rcls gdrive                                 # Recursively list files with sizes
rcls gdrive --max-depth 1                    # List files only one level deep
rct "visa:Visa Application"                  # Tree, two levels deep
rctree gdrive:Papers --level 3               # Tree with optional depth limit
rcsize visa                                 # Total size and file count
rcspace gdrive                              # Quota, if the provider supports it
rcbrowse visa                               # Interactive storage explorer
rcpick                                      # Pick any remote with FZF, then explore
# In the explorer: arrows/hjkl navigate, q quits; d can delete files/directories.

# ── MOUNT ─────────────────────────────────────────────────────────────────────
rcmount visa                                # Mount at ~/visa-rclone
rcmount gdrive:                             # Mount at ~/gdrive-rclone
rcumount visa:                              # Unmount and remove the empty folder
# Both NAME and NAME: use the SAME mount directory.
# Mount creates a missing folder or reuses an existing one; mounted = no-op.
# Unmount also works when already unmounted or when the folder is missing.
# Only empty folders are removed; any local files are left untouched.

# ── COPY: SOURCE FIRST, DESTINATION SECOND ─────────────────────────────────────
rcpull visa ~/Downloads/Visa                 # Remote -> local
rcpush ~/Documents gdrive                    # Local -> remote
rcpull "visa:Visa Application" ~/local       # Copy a remote folder's contents
rcpush ~/local "visa:Visa Application"       # Copy local contents to a remote folder
rccopy ~/Documents gdrive:Documents          # Generic copy, with progress
rccopy visa gdrive                           # Copy between two remote roots
rcto ./report.pdf gdrive:Papers/final.pdf     # Copy one file to an exact destination
rccopy ~/Documents gdrive --include '*.pdf'   # Options are forwarded
# Copies may update existing files; extra destination files are not deleted.
# Directory copies transfer the CONTENTS, not the enclosing directory itself.

# ── BARE REMOTES VS LOCAL FOLDERS ──────────────────────────────────────────────
# rccopy/rcto/rcplan/rcmirror recognize bare names from `rcremotes` on either side.
# If a local folder has the same name as a remote, write ./visa, not visa.
# rcpush/rcpull and directional sync/preview helpers always keep LOCAL paths local.

# ── COPY PREVIEWS ──────────────────────────────────────────────────────────────
rcdry-down visa ~/local                      # Preview a remote -> local COPY
rcdry-up ~/local visa:                       # Preview a local -> remote COPY
rccopy ~/local gdrive --dry-run              # Preview a generic copy

# ── MIRROR: DESTINATION DELETIONS ARE POSSIBLE ──────────────────────────────────
rcplan ~/local visa                          # Preview a local -> remote SYNC
rcplan visa ~/local                          # Preview a remote -> local SYNC
rcmirror ~/local visa                        # Perform a local -> remote SYNC
rcsync-down visa ~/local                     # Mirror remote -> local
rcsync-up ~/local visa:                      # Mirror local -> remote
rcsync-up ~/local visa --dry-run             # Preview the exact directional sync
# Sync makes the destination match the source, including removing extra files.
# rcdry-up/down preview COPY; use rcplan or --dry-run to preview SYNC deletions.

# ── STATUS: REMOTE FIRST, LOCAL DIRECTORY SECOND ───────────────────────────────
rcgit visa ~/local                           # Three-section comparison
rcstatus visa: ~/local                       # Combined comparison with symbols
rcremote-only gdrive ~/local                 # Files only on the remote
rclocal-only gdrive: ~/local                 # Files only in the local directory
rcdiff "visa:Visa Application" ~/local       # Files present on both but different
# Symbols: = identical, - only local, + only remote, * different, ! error.
# Checks do not change either side; differences can produce a nonzero exit code.
EOF
}
