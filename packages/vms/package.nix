{ pkgs, self }:
let
  mkVm = name: hostmodulepath:
    (self.inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit self; };
      modules = [
        "${self.inputs.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
        { os.hostname = name; }
        hostmodulepath
        ./qemu.nix
        self.outputs.nixosModules.default
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
  (self.lib.getDirs ../../hosts)
