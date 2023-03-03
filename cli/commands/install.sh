option_help() {
    cat <<-_EOF

Usage: ryzst install <sub-command>
    
Sub-Commands:
    system      --  install system configuration
    usb         --  make custom usb installer
    yubikey     --  setup a yubikey

_EOF
}

case "$1" in 
    --help)
        option_help
    ;;
    system)
        # pre checks
        shift;
        if ! cat /proc/cmdline | grep " root=LABEL=ryzst-iso " &>/dev/null; then
            printf "ERROR: Please boot into the installation media first\n\n"
            exit 1
        fi
        if ! ls /sys/firmware/efi &>/dev/null; then
            printf "ERROR: UEFI not detected.\n"
            exit 1
        fi
        # confirm installation
        printf "Proceed with system installation:\n"
        CONFIRM=$(printf "yes\nno" | fzf --prompt="Proceed with system installation: $SELECTION > " --reverse)
        printf "$CONFIRM\n\n"
        if [[ $CONFIRM = "" || $CONFIRM = "no" ]]; then
            printf "Canceled. Run \"sudo ryzst system intall\" to restart installation\n\n"
            exit 1
        fi
        # setup wifi
        if ls /sys/class/ieee80211/*/device/net &>/dev/null; then
            printf "Connect to wifi:\n"
            fzf-wifi
            printf "\n"
        fi
        # validate network connection
        printf "Validating Internet connection...\n"
        if curl https://cache.nixos.org &>/dev/null; then
            printf "success\n\n"
        else   
            printf "ERROR: Cannot connect to Internet\n"
            exit 1
        fi
        # select disk
        DISKS=$(lsblk -A -o TYPE,PATH,SIZE,MOUNTPOINTS | awk '$1 == "disk" && $4 != "[SWAP]" {print  $2, $3}')
        DISK=$(printf "%s\n" "${DISKS[@]}" | fzf --prompt="Select Disk to use: " --reverse)
        if [[ $DISK = "" ]]; then
            printf "ERROR: Invalid selection\n\n"
            exit 1
        fi
        DISK=$(echo $DISK | awk '{ print $1 }')
        CHECK_DISK=$(lsblk -no MOUNTPOINTS $DISK)
        if [[ $CHECK_DISK != "" ]]; then
            printf "ERROR: Please unmount the drive first\n\n"
            exit 1
        fi
        printf "Confirm partition/format to: $DISK\n"
        CONFIRM=$(printf "yes\nno" | fzf --prompt="Confirm partition/format to: $DISK > " --reverse)
        printf "$CONFIRM\n\n"
        if [[ $CONFIRM = "" || $CONFIRM = "no" ]]; then
            printf "Canceled\n\n"
            exit 1
        fi
        # partition
        printf "Partitioning Disk:\n"
        sgdisk --zap-all $DISK
        sgdisk -n1:1M:+512M -t1:EF00 -c1:ESP $DISK
        sgdisk -n2:0:0      -t2:BF00 -c2:NIX $DISK 
        sync && udevadm settle && sleep 3
        # format
        printf "Formatting Filesystems:\n"
        DISK_PART_1=$(lsblk $DISK -no PARTLABEL,PATH | awk '$1 == "ESP" { print $2 }')
        DISK_PART_2=$(lsblk $DISK -no PARTLABEL,PATH | awk '$1 == "NIX" { print $2 }')
        mkfs.vfat -n BOOT $DISK_PART_1
        mkfs.ext4 -L ROOT $DISK_PART_2
        # mount
        printf "Mounting:\n"
        mkdir /mnt
        mount $DISK_PART_2 /mnt
        mkdir -p /mnt/boot/efi
        mount $DISK_PART_1 /mnt/boot/efi
        printf "success\n\n"
        # select host
        printf "Select Host:\n"
        rm -rf /tmp/ryzst
        git clone --depth 1 $REPO_URL /tmp/ryzst &>/dev/null
        HOSTS=$(ls /tmp/ryzst/hosts)
        HOST=$(printf "%s\n" "${HOSTS[@]}" | fzf --prompt="Select Host to Install: " --reverse)
        printf "$HOST\n\n"
        if [[ $HOST = "" ]]; then
            printf "ERROR: Invalid selection\n\n"
            exit 1
        fi
        CONFIRM=$(printf "yes\nno" | fzf --prompt="Confirm host to install: $HOST > " --reverse)
        if [[ $CONFIRM = "" || $CONFIRM = "no" ]]; then
            printf "Canceled\n\n"
            exit 1
        fi
        # install nixos from flake
        printf "Installing system:\n"
        nixos-install --flake $REPO\#$HOST --root /mnt --no-root-password
        # todo: register devices....
        # finish
        umount -Rl /mnt
        CONFIRM=$(printf "reboot" | fzf --prompt="Remove installation media and finish installation: > " --reverse)
        printf "$CONFIRM\n\n"
        if [[ $CONFIRM = ""  ]]; then
            printf "Canceled\n\n"
            exit 1
        fi
        reboot
    ;;
    usb)
        shift;
        USBSTORAGE=$(lsblk -A -o TRAN,PATH,VENDOR,SIZE | awk '$1 == "usb" {print $2, $3, $4}')
        if [[ $USBSTORAGE = "" ]]; then
            printf "ERROR: No usb storage devices plugged in\n\n"
            exit 1
        fi
        SELECTION=$(echo $USBSTORAGE | fzf --prompt="Select USB Device to format: " --reverse)
        printf "\nSelect USB Device to format:\n"
        printf "$SELECTION\n\n"
        SELECTION=$(echo $SELECTION | awk '{ print $1 }')
        if [[ $SELECTION = "" ]]; then
            printf "Invalid selection\n\n"
            exit 1
        fi
        printf "Confirm to write to: $SELECTION\n"
        CONFIRM=$(printf "yes\nno" | fzf --prompt="Confirm to write to: $SELECTION > " --reverse)
        printf "$CONFIRM\n\n"
        if [[ $CONFIRM = "" || $CONFIRM = "no" ]]; then
            printf "Canceled\n\n"
            exit 1
        fi
        RESULT=$(nix build $REPO"#images.live.config.system.build.isoImage" --print-out-paths) &&
        printf "\ndd if=$RESULT/iso/live.iso of=$SELECTION\n" &&
        sudo dd if=$RESULT/iso/live.iso of=$SELECTION bs=4M conv=fsync status=progress
    ;;
    yubikey)
        shift;
        # select yubikey
        YUBIKEYS=$(ykman list)
        if [[ $YUBIKEYS = "" ]]; then
            printf "ERROR: No yubikey plugged in\n\n"
            exit 1
        fi
        YUBIKEY=$(printf "$YUBIKEYS" | fzf --prompt="Select USB Device to format: " --reverse)
        SERIAL=$(printf "$YUBIKEY" | sed -n -e 's/^.*Serial: //p')
        # enter lock code
        CODE=$(read -p "Enter Yubikey Lock Code: ")
        #ykman -d $SERIAL config set-lock-code --lock-code $CODE
        printf "\n"
        # enable/disable applications
        printf "Enabling/Disabling Yubikey Applications:\n"
        ykman -d $SERIAL config usb --enable FIDO2 -f && sleep 1
        ykman -d $SERIAL config usb --disable OTP -f && sleep 1
        ykman -d $SERIAL config usb --disable U2F -f && sleep 1
        ykman -d $SERIAL config usb --disable OATH -f && sleep 1
        ykman -d $SERIAL config usb --disable PIV -f && sleep 1
        # todo again: https://github.com/drduh/YubiKey-Guide
        ykman -d $SERIAL config usb --disable OPENPGP -f && sleep 1
        ykman -d $SERIAL config usb --disable HSMAUTH -f && sleep 1
        ykman -d $SERIAL config nfc --disable-all -f && sleep 1
        printf "\n"
        # fido
        printf "Set FIDO2 Access Pin:\n"
        ykman fido access change-pin
        printf "\n"
        ssh-keygen -t ed25519-sk -O resident -O verify-required
        pamu2fcfg -N
        # set lock code
        #ykman -d $SERIAL config set-lock-code --generate
    ;;
    *)
        echo "INVALID INPUT: $1"
    ;;
esac