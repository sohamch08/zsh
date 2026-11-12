# Service status: running state, PID, restart count
alias qstatus='launchctl print "gui/$(id -u)/local.quartz" | rg "state =|pid =|runs =|last exit code|last terminating signal"'

# Watch requests, rebuilds, and errors live. Ctrl+C to exit.
alias qlogs='tail -n 30 -F "$HOME/Library/Logs/quartz.log" "$HOME/Library/Logs/quartz-error.log"'

# Show recent errors and warnings
alias qerrors='tail -n 50 "$HOME/Library/Logs/quartz-error.log"'

# Show which process is listening
alias qport='lsof -nP -iTCP:8090 -sTCP:LISTEN'

# Check local HTTP response and response time
alias qcheck='curl --max-time 5 -sS -o /dev/null -w "HTTP %{http_code} | %{time_total}s\n" http://127.0.0.1:8090/'

# Check HTTPS through Tailscale
alias qremote='curl --max-time 8 -sS -o /dev/null -w "HTTP %{http_code} | %{time_total}s\n" https://soham-mac.tailef3442.ts.net/'

# Show Tailscale proxy configuration
alias qserve='tailscale serve status'

# Open the hosted site
alias qopen='open https://soham-mac.tailef3442.ts.net/'

# Restart Quartz, triggering a fresh build
alias qrestart='launchctl kickstart -k "gui/$(id -u)/local.quartz"'

# Go to the Quartz repository
alias qcd='cd "$HOME/github/quartz"'
