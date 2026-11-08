BEGIN {
    if (cols < 60) cols = 80
    cyan = "\033[1;38;5;81m"
    gold = "\033[38;5;222m"
    dim  = "\033[38;5;240m"
    soft = "\033[38;5;252m"
    off  = "\033[0m"
}
/^=/ {
    sub(/^=+[[:space:]]*/, "")
    sub(/[[:space:]]*=+$/, "")
    printf "\n  %s%s%s\n", cyan, $0, off
    next
}
/^[[:alnum:]_.-]+[[:space:]]*[:=]/ {
    match($0, /^[[:alnum:]_.-]+/)
    label = substr($0, 1, RLENGTH)
    value = substr($0, RLENGTH + 1)
    sub(/^[[:space:]]*[:=][[:space:]]*/, "", value)

    printf "  %s%-18s%s │ %s", gold, label, dim, soft
    room = cols - 24

    while (length(value) > room) {
        printf "%s%s\n%20s%s │ %s", substr(value, 1, room), off, "", dim, soft
        value = substr(value, room + 1)
    }

    printf "%s%s\n", value, off
    next
}
{printf "  %s%s%s\n", soft, $0, off}
