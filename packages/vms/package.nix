{ pkgs, self }:
# TODO: remove vms from packages...
let
  inherit (self.inputs) nixpkgs;
  mkVm = name: value:
    (nixpkgs.lib.nixosSystem {
      specialArgs = { inherit self; };
      modules = [
        "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
        self.outputs.settingsModules.default
        value.module
        { os.hostname = name; }
        { nixpkgs.pkgs = pkgs; }
        ./qemu.nix
      ];
    }).config.system.build.vm;
  mkVmScript = name: path:
    pkgs.writeShellApplication {
      name = "vm-${name}";
      runtimeInputs = [ ];
      text = ''
        TMPDIR=$(mktemp -d -t run-${name}-vm-XXXXXXX)
        trap 'rm -rf "$TMPDIR"' EXIT
        (cd "$TMPDIR"; ${mkVm name path}/bin/run-${name}-vm)
      '';
    };
in
pkgs.lib.attrsets.foldlAttrs
  (acc: n: v: { "vm-${n}" = mkVmScript n v; } // acc)
{ }
  self.domain.mek.hosts
