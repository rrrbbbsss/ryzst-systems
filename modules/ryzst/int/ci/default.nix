{ ... }:
{
  imports = [
    ./client.nix
    ./server.nix
    # TODO: move this somewhere else
    ./laminar.nix
  ];
}
