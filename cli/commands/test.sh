option_help() {
    cat <<-_EOF

Usage: ryzst test <sub-command>
    
Sub-Commands:
    vm          --  run a test vm of current system
    iso         --  run a test vm of an iso

_EOF
}

case "$1" in 
    --help)
        option_help
    ;;
    vm)
        shift;
        # annoying state can linger, so just throw it away when done testing
        nix run ".#vms.$1.config.system.build.vm" &&
        rm "$1.qcow2"
    ;;
    iso)
        shift;
        RESULT=$(nix build ".#isos.$1.config.system.build.isoImage" --print-out-paths) &&
        qemu-kvm -smp 4 -m 4096 -vga qxl -cdrom $RESULT/iso/$1.iso 
    ;;
    *)
        echo "INVALID INPUT: $1"
    ;;
esac