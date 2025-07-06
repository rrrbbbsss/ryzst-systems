self:
let
  inherit (self.inputs) nixpkgs;
  microkanren = import ./microkanren.nix nixpkgs;
  nand-game = import ./nand-game.nix microkanren;
in
{
  logic = {
    inherit microkanren nand-game;
  };
}
