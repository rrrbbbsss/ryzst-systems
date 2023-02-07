option_help() {
    cat <<-_EOF

Usage: ryzst update <sub-command>
    
Sub-Commands:
    system      --  update the current system

_EOF
}

case "$1" in 
    --help)
        option_help
    ;;
    system)
        shift;
        sudo nixos-rebuild --refresh switch --flake "$REPO"\#
    ;;
    *)
        echo "INVALID INPUT: $1"
    ;;
esac