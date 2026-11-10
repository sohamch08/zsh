# ----- CPU and memory -----
alias cpuinfo='lscpu | bat -p -l cpuinfo'
alias freee='free -h | bat -l conf -p'

# ----- Sensors -----
alias sensors='sensors | bat -l cpuinfo -p'

# ----- Storage and mounts -----
alias lsbc='lsblk | bat -l conf -p'
alias blockdevices='lsblk -f | bat -p -l fstab --wrap=never'
alias mounts='findmnt | bat -p -l fstab --wrap=never'

# ----- Connected hardware -----
alias pci='lspci | bat -p -l properties'
alias usb='lsusb | bat -p -l fstab'

# ----- GPG -----
alias gpg-fingerprint="gpg --with-colons --fingerprint | awk -F: '\$1==\"pub\"{p=1} \$1==\"fpr\" && p{print \$10; p=0}'"
