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
        # confirm installation
        cat /proc/cmdline | grep " root=LABEL=ryzst-live-iso " &>/dev/null
        if [[ $? -ne 0 ]]; then
            printf "ERROR: Please boot into the installation media first\n\n"
            exit 1
        fi
        printf "Proceed with system installation:\n"
        CONFIRM=$(printf "yes\nno" | fzf --prompt="Proceed with system installation: $SELECTION > " --reverse)
        printf "$CONFIRM\n\n"
        if [[ $CONFIRM = "" || $CONFIRM = "no" ]]; then
            printf "Canceled\n\n"
            exit 1
        fi
        # setup wifi
        ls /sys/class/ieee80211/*/device/net &>/dev/null
        if [[ $? = 0 ]]; then
            printf "Connect to wifi:\n"
            fzf-wifi
            printf "\n"
        fi
        # validate network connection
        printf "Validating Internet connection...\n"
        curl https://cache.nixos.org &>/dev/null 
        if [[ $? -ne 0 ]]; then
            printf "ERROR: Cannot connect to Internet\n"
            exit 1
        else   
            printf "success\n\n"
        fi
        # select host
        rm -rf /tmp/ryzst
        git clone --depth 1 $REPO_URL /tmp/ryzst &>/dev/null
        HOSTS=$(ls /tmp/ryzst/hosts)
        HOST=$(printf "%s\n" "${HOSTS[@]}" | fzf --prompt="Select Host to Install: " --reverse)
        if [[ $HOST = "" ]]; then
            printf "Invalid selection\n\n"
            exit 1
        fi
        # select disk
        DRIVES=$(lsblk -A -o TYPE,PATH,SIZE,MOUNTPOINTS | awk '$1 == "disk" && $4 != "[SWAP]" {print  $2, $3}')
        DRIVE=$(printf "%s\n" "${DRIVES[@]}" | fzf --prompt="Select Drive to use: " --reverse)
        if [[ $DRIVE = "" ]]; then
            printf "Invalid selection\n\n"
            exit 1
        fi
        DRIVE=$(echo $DRIVE | awk '{ print $1 }')
        printf "Confirm partition/format to: $DRIVE\n"
        CONFIRM=$(printf "yes\nno" | fzf --prompt="Confirm partition/format to: $DRIVE > " --reverse)
        printf "$CONFIRM\n\n"
        if [[ $CONFIRM = "" || $CONFIRM = "no" ]]; then
            printf "Canceled\n\n"
            exit 1
        fi
        # partition disk
        # boot pool
        
        # format disk
        # mount disk

        # install nixos from flake
        
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
        echo "todo..."
    ;;
    *)
        echo "INVALID INPUT: $1"
    ;;
esac