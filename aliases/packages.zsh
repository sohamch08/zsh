# ----- DNF -----
alias i='sudo dnf install -y'
alias u='sudo dnf upgrade --refresh -y'
alias uninstall='sudo dnf remove -y'
alias autoremove='sudo dnf autoremove -y'
alias lock='sudo dnf versionlock add'
alias unlock='sudo dnf versionlock delete'
alias locks='dnf versionlock list'
