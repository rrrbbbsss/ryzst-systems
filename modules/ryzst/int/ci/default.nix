{ ... }:
{
  imports = [
    ./client-rpc.nix
    ./client-web.nix
    ./server.nix
    # TODO: move this somewhere else
    ./laminar.nix
  ];
}
