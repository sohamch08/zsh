# DNF package management.
alias i='sudo dnf install -y'
alias u='sudo dnf upgrade --refresh -y'
alias autoremove='sudo dnf autoremove -y'
alias lock='sudo dnf versionlock add'
alias unlock='sudo dnf versionlock delete'
alias uninstall='sudo dnf remove -y'
alias locks='dnf versionlock list'

# Flatpak package inspection.
flatpak() {
  if [[ "$1" == "list" && $# -eq 1 ]]; then
    command flatpak list --runtime --columns=name,application,branch,size
  else
    command flatpak "$@"
  fi
}

# Hardware and resource inspection.
alias lsbc='lsblk | bat -l conf -p'
alias freee='free -h | bat -l conf -p'
alias sensors='sensors | bat -l cpuinfo -p'
alias cpuinfo='lscpu | bat -p -l cpuinfo'
alias blockdevices='lsblk -f | bat -p -l fstab --wrap=never'
alias pci='lspci | bat -p -l properties'
alias usb='lsusb | bat -p -l fstab'
alias mounts='findmnt | bat -p -l fstab --wrap=never'

# GPG key inspection.
alias gpg-fingerprint="gpg --with-colons --fingerprint | awk -F: '\$1==\"pub\"{p=1} \$1==\"fpr\" && p{print \$10; p=0}'"
