{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ryzst.int.remote-build.server;
  enable = cfg.nodes?${config.networking.hostName};
  clientsIps =
    attrsets.foldlAttrs (acc: n: v: "${v.ip}, ${acc}") ""
      config.ryzst.int.remote-build.client.nodes;
  clientsSSHKeys =
    attrsets.foldlAttrs (acc: n: v: [ v.keys.ssh ] ++ acc) [ ]
      config.ryzst.int.remote-build.client.nodes;
in
{
  options.ryzst.int.remote-build.server = {
    enable = mkEnableOption "Internal remote build service";
    nodes = mkOption {
      description = "Nodes the service is deployed to";
      type = types.attrs;
      default = { };
    };
    interface = mkOption {
      description = "The interface to bind the service to";
      type = types.str;
      default = "wg0";
    };
    port = mkOption {
      description = "The port for the service to listen on";
      type = types.int;
      default = 22;
    };
  };
  config = mkIf enable {

    networking.firewall.extraInputRules = ''
      iifname "wg0" counter ip6 saddr { ${clientsIps} } tcp dport ${builtins.toString cfg.port} accept
    '';


    nix.settings.trusted-users = [ "nix-rbuild" ];

    users.users.nix-rbuild = {
      description = "Nix Remote Build user";
      isSystemUser = true;
      group = "nix-rbuild";
      useDefaultShell = true;
    };
    users.groups.nix-rbuild = { };

    services.openssh.enable = true;

    services.openssh.extraConfig = ''
      Match User nix-rbuild
        AllowAgentForwarding no
        AllowTcpForwarding no
        PermitTTY no
        PermitTunnel no
        X11Forwarding no
        ForceCommand ${config.nix.package.out}/bin/nix-store --serve --write
      Match All
    '';
    users.users.nix-rbuild.openssh.authorizedKeys.keys = clientsSSHKeys;
  };
}
