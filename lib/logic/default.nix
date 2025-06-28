self:
# https://www.youtube.com/watch?v=fd8uXlrr5is
let
  inherit (self.inputs) nixpkgs;
  microkanren = import ./microkanren.nix nixpkgs;
  nand-game = import ./nand-game.nix microkanren;
in
{
  inherit microkanren nand-game;
}
