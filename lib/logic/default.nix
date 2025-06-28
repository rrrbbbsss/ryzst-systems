self:
let
  inherit (self.inputs) nixpkgs;
  microkanren = import ./microkanren.nix nixpkgs;
  nand-game = import ./nand-game.nix microkanren;
in
{
  inherit microkanren nand-game;
}
