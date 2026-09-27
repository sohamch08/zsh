# ─── RCLONE FUNCTIONS (remote specific) ───────────────────────────────────────

# List files on any remote (human readable)
rcls() {
    rclone ls "$1" --human-readable
}

# Tree view of any remote via eza (mounts temporarily)
rctree() {
    local remote="$1"
    local mount="$HOME/${remote}-mounts"
    mkdir -p "$mount"
    rclone mount "$remote:" "$mount" --daemon --vfs-cache-mode full
    lt "$mount"
}

# Mount a remote
rcmount() {
    local remote="$1"
    local mount="$HOME/${remote}-mounts/"
    mkdir -p "$mount"
    rclone mount "$remote:" "$mount" --daemon --vfs-cache-mode full
    echo "Mounted $remote: at $mount"
}

# Unmount a remote
rcumount() {
    local remote="$1"
    local mount="$HOME/${remote}-mounts/"
    fusermount -u "$mount" && echo "Unmounted $remote:"
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
    echo "=  identical"
    echo "<  only on local (local ahead)"
    echo ">  only on remote (remote ahead)"
    echo "*  different on both"
    echo "──────────────────────────────"
    rclone check "$1" "$2" --combined -
}

# Files only on remote
rcremote-only() {
    echo "Remote ahead — files only on $1:"
    rclone check "$1" "$2" --missing-on-destination -
}

# Files only on local
rclocal-only() {
    echo "Local ahead — files only in $2:"
    rclone check "$1" "$2" --missing-on-source -
}

# Files that differ
rcdiff() {
    echo "Files that differ between $1 and $2:"
    rclone check "$1" "$2" --differ -
}

# Full git-like summary
rcgit() {
    local remote="$1"
    local local_path="$2"
    echo ""
    echo "📡 Remote: $remote"
    echo "💻 Local:  $local_path"
    echo "──────────────────────────────────────"

    echo ""
    echo "🔼 Local ahead (only on local):"
    rclone check "$remote" "$local_path" --missing-on-source - 2>/dev/null || echo "  none"

    echo ""
    echo "🔽 Remote ahead (only on remote):"
    rclone check "$remote" "$local_path" --missing-on-destination - 2>/dev/null || echo "  none"

    echo ""
    echo "📝 Different on both:"
    rclone check "$remote" "$local_path" --differ - 2>/dev/null || echo "  none"

    echo "──────────────────────────────────────"
}
