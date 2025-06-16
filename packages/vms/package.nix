{ pkgs, self }:
let
  inherit (self.inputs) nixpkgs;
  mkVm = name: hostmodulepath:
    (nixpkgs.lib.nixosSystem {
      specialArgs = { inherit self; };
      modules = [
        "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
        { os.hostname = name; }
        hostmodulepath
        ./qemu.nix
        self.outputs.nixosModules.default
        { nixpkgs.pkgs = pkgs; }
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
