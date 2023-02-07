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
        shift;
        echo "todo..."
        # validate network connection
        # select host
        # partition+format+mount disk(s)
        # install nixos from flake
        # chroot/nixo-enter and change password(s)
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
            exit 0
        fi
        printf "Confirm to write to: $SELECTION\n"
        CONFIRM=$(printf "yes\nno" | fzf --prompt="Confirm to write to: $SELECTION > " --reverse)
        printf "$CONFIRM\n\n"
        if [[ $CONFIRM = "" || $CONFIRM = "no" ]]; then
            printf "Canceled\n\n"
            exit 0
        fi
        RESULT=$(nix build $REPO"#images.live.config.system.build.isoImage" --print-out-paths) &&
        printf "\ndd if=$RESULT/iso/live.iso of=$SELECTION\n" &&
        sudo dd if=$RESULT/iso/live.iso of=$SELECTION bs=4M conv=fsync status=progress
    ;;
    yubikey)
        shift;
        echo "todo..."
    ;;
    *)
        echo "INVALID INPUT: $1"
    ;;
esac