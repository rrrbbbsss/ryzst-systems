option_help() {
    cat <<-_EOF

Usage: ryzst test <sub-command>
    
Sub-Commands:
    vm          --  run a test vm of current system
    usb         --  run a test vm of the live iso

_EOF
}

case "$1" in 
    --help)
        option_help
    ;;
    vm)
        shift;
        # annoying state can linger, so just throw it away when done testing
        nix run ".#vms.$(hostname).config.system.build.vm" &&
        rm "$(hostname).qcow2"
    ;;
    usb)
        shift;
        qemu-img create -f qcow2 test-drive.qcow2 40G
        RESULT=$(nix build ".#images.live.config.system.build.isoImage" --print-out-paths) &&
        qemu-kvm -smp 4 -m 4096 -vga qxl -cdrom $RESULT/iso/live.iso -drive format=qcow2,file='./test-drive.qcow2' &&
        rm test-drive.qcow2
    ;;
    *)
        echo "INVALID INPUT: $1"
    ;;
esac