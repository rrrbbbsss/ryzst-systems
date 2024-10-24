{ config, lib, pkgs, ... }:
with lib;
let
  mkAuthorizedKey = key: ip:
    (concatStringsSep "," [
      "cert-authority"
      ''principals="hello"''
      ''command="${config.ryzst.int.ci.client-rpc.rpcScript}/bin/laminar-rpc queue hello"''
      "restrict"
      "no-port-forwarding"
      "no-X11-forwarding"
      "no-agent-forwarding"
      "no-pty"
      "no-user-rc"
      ''from="${ip}"''
    ]) + " ${key}";
  cfg = config.ryzst.int.ci.server;
  enable = cfg.nodes?${config.networking.hostName};
  client-webIps = attrsets.foldlAttrs
    (acc: n: v: "${v.ip}, ${acc}")
    ""
    config.ryzst.int.ci.client-web.nodes;
  client-rpcIps = attrsets.foldlAttrs
    (acc: n: v: "${v.ip}, ${acc}")
    ""
    config.ryzst.int.ci.client-rpc.nodes;
  client-rpcKeys =
    attrsets.foldlAttrs
      (acc: n: v: [ (mkAuthorizedKey v.keys.ssh v.ip) ] ++ acc) [ ]
      config.ryzst.int.ci.client-rpc.nodes;
in
{
  options.ryzst.int.ci.server = {
    enable = mkEnableOption "Internal ci service";
    nodes = mkOption {
      description = "Nodes the service is deployed to";
      type = types.attrs;
      default = { };
    };
    web-port = mkOption {
      description = "The port for the web service to listen on";
      type = types.int;
      default = 8080;
    };
    rpc-port = mkOption {
      description = "The port for the rpc service to listen on";
      type = types.int;
      default = 22;
    };
  };
  config = mkIf enable {

    networking.firewall.extraCommands = ''
      ${pkgs.nftables}/bin/nft add rule ip6 filter nixos-fw iifname "wg0" counter ip6 saddr { ${client-webIps} } tcp dport ${builtins.toString cfg.web-port} jump nixos-fw-accept

      ${pkgs.nftables}/bin/nft add rule ip6 filter nixos-fw iifname "wg0" counter ip6 saddr { ${client-rpcIps} } tcp dport ${builtins.toString cfg.rpc-port} jump nixos-fw-accept
    '';

    services.laminar = {
      enable = true;
      title = "Laminar";
      #TODO: tls
      webInterface = ''
        [${cfg.nodes.${config.networking.hostName}.ip}]:${toString cfg.web-port}
      '';
      rpcInterface = "unix:/run/laminar/rpc.sock";
      contexts = {
        hello = {
          executors = 1;
          jobs = [ "hello" ];
        };
      };
      jobs = {
        hello = {
          timeout = 120;
          description = "this is a test";
          run = getExe (pkgs.writeShellApplication {
            name = "testeroni";
            runtimeInputs = [ ];
            text = ''
              pwd
              sleep 5
              echo 123
            '';
          });
        };
      };
    };

    #rpc
    services.openssh.enable = true;
    users.users.laminar.openssh.authorizedKeys.keys = client-rpcKeys;
    services.openssh.extraConfig = ''
      Match User laminar
        AllowAgentForwarding no
        AllowTcpForwarding no
        PermitTTY no
        PermitTunnel no
        X11Forwarding no
      Match All
    '';
  };
}
