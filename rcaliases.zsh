# ─── RCLONE GENERAL ALIASES ───────────────────────────────────────────────────

# List all configured remotes
alias rcremotes='rclone listremotes'

# Show rclone config
alias rcconfig='sed "s/token = .*/token = ██████████████████████████████/" ~/.config/rclone/rclone.conf | bat --language=ini'
# alias rcconfig='bat ~/.config/rclone/rclone.conf'

# Edit rclone config
alias rcedit='nvim ~/.config/rclone/rclone.conf'

# Show rclone log
alias rclog='tail -f ~/.config/rclone/rclone.log'

# Clear rclone log
alias rclog-clear='> ~/.config/rclone/rclone.log'

# Show all rclone aliases and usage
rchelp() {
    bat --language=bash --style=plain <<'EOF'
# ── GENERAL ──────────────────────────────────────────────
rchelp                                  # Show this help
rcremotes                               # List all configured remotes
rcconfig                                # Show rclone config
rcedit                                  # Edit config in nvim
rclog                                   # Live tail of log
rclog-clear                             # Clear log

# ── LISTING ──────────────────────────────────────────────
rcls visa:                              # List files on remote
rctree gdrive:                          # Tree view without mounting

# ── MOUNT ────────────────────────────────────────────────
rcmount visa:                           # Mount remote
rcumount visa:                          # Unmount remote
# Mounts to: ~/<remotename>-mounts

# ── TRANSFER ─────────────────────────────────────────────
rcpull "visa:Visa Application" ~/local  # Download remote → local
rcpush ~/local "visa:Visa Application"  # Upload local → remote

# ── SYNC (DESTRUCTIVE) ───────────────────────────────────
rcsync-down "visa:Visa Application" ~/local  # Mirror remote → local
rcsync-up ~/local "visa:Visa Application"    # Mirror local → remote
# ⚠ Always dry run first!

# ── DRY RUN (SAFE PREVIEW) ───────────────────────────────
rcdry-down "visa:Visa Application" ~/local   # Preview download
rcdry-up ~/local "visa:Visa Application"     # Preview upload

# ── STATUS (GIT-LIKE) ────────────────────────────────────
rcgit "visa:Visa Application" ~/local        # Full git-like summary
rcstatus "visa:Visa Application" ~/local     # Diff with symbols
rcremote-only "visa:Visa Application" ~/local  # Remote ahead
rclocal-only "visa:Visa Application" ~/local   # Local ahead
rcdiff "visa:Visa Application" ~/local         # Files that differ

# Symbols: = identical  - only local  + only remote  * different  ! error
EOF
}


# ─── RCLONE FUNCTIONS (remote specific) ───────────────────────────────────────

# List files on any remote (human readable)
rcls() {
    rclone ls "$1" --human-readable
}

# Tree view of any remote via eza (mounts temporarily)
rctree() {
  local remote="${1%:}"

  if (( $# != 1 )) || [[ -z $remote || $remote == *[:/]* ]]; then
    print -u2 -- 'Usage: rctree REMOTE or REMOTE:'
    return 2
  fi

  command rclone tree "${remote}:"
}

# Mount a remote
rcmount() {
  local remote="${1%:}"

  if (( $# != 1 )) || [[ -z $remote || $remote == *[:/]* ]]; then
    print -u2 -- 'Usage: rcmount REMOTE or REMOTE:'
    return 2
  fi

  local mount="$HOME/${remote}-mounts"

  command mkdir -p -- "$mount" || return
  command rclone mount "${remote}:" "$mount" \
    --daemon --vfs-cache-mode full || return

  print -r -- "Mounted ${remote}: at $mount"
}

# Unmount a remote
rcumount() {
  local remote="${1%:}"

  if (( $# != 1 )) || [[ -z $remote || $remote == *[:/]* ]]; then
    print -u2 -- 'Usage: rcumount REMOTE or REMOTE:'
    return 2
  fi

  local mount="$HOME/${remote}-mounts"

  command fusermount -u -- "$mount" || return
  print -r -- "Unmounted ${remote}:"
}

# Copy remote → local
rcpull() {
    rclone copy "$1" "$2" --progress
}

# Copy local → remote
rcpush() {
    rclone copy "$1" "$2" --progress
}

# Sync remote → local
rcsync-down() {
    rclone sync "$1" "$2" --progress
}

# Sync local → remote
rcsync-up() {
    rclone sync "$1" "$2" --progress
}

# Dry run: preview download
rcdry-down() {
    rclone copy "$1" "$2" --dry-run --progress
}

# Dry run: preview upload
rcdry-up() {
    rclone copy "$1" "$2" --dry-run --progress
}

# ─── RCLONE STATUS (git-like) ─────────────────────────────────────────────────

# Full status with symbols
rcstatus() {
  print -r -- '=  identical'
  print -r -- '-  only on local'
  print -r -- '+  only on remote'
  print -r -- '*  different on both'
  print -r -- '!  error checking the file'
  print -r -- '──────────────────────────────'
  command rclone check "$1" "$2" --combined -
}

# Files only on remote
rcremote-only() {
    echo "Remote ahead — files only on $1:"
    rclone check "$1" "$2" --missing-on-dst -
}

# Files only on local
rclocal-only() {
    echo "Local ahead — files only in $2:"
    rclone check "$1" "$2" --missing-on-src -
}

# Files that differ
rcdiff() {
    echo "Files that differ between $1 and $2:"
    rclone check "$1" "$2" --differ -
}

# Full git-like summary.
rcgit() {
  if (( $# != 2 )); then
    print -u2 -- 'Usage: rcgit REMOTE:PATH LOCAL_PATH'
    return 2
  fi

  local remote="$1"
  local local_path="$2"
  local -i result=0

  print
  print -r -- "📡 Remote: $remote"
  print -r -- "💻 Local:  $local_path"
  print -r -- '──────────────────────────────────────'

  print
  print -r -- '🔼 Local ahead (only on local):'
  command rclone check "$remote" "$local_path" \
    --missing-on-src - || result=$?

  print
  print -r -- '🔽 Remote ahead (only on remote):'
  command rclone check "$remote" "$local_path" \
    --missing-on-dst - || result=$?

  print
  print -r -- '📝 Different on both:'
  command rclone check "$remote" "$local_path" \
    --differ - || result=$?

  print -r -- '──────────────────────────────────────'
  return "$result"
}

