{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ryzst.int.git.server;
  enable = cfg.nodes?${config.networking.hostName};
  clientsIps = attrsets.foldlAttrs
    (acc: n: v: "${v.ip}, ${acc}")
    ""
    config.ryzst.int.git.client.nodes;
  userKeys = attrsets.foldlAttrs
    (acc: n: v: acc //
      { ${n} = [ (builtins.readFile v.keys.ssh) ]; })
    { }
    config.ryzst.idm.users;
  hostKeys = attrsets.foldlAttrs
    (acc: n: v: acc //
      { ${n} = [ v.keys.ssh ]; })
    { }
    config.ryzst.int.git.client.nodes;
  admins = attrNames config.ryzst.idm.groups.admins;
  hosts = attrNames config.ryzst.int.git.client.nodes;

  hosts-job = pkgs.writeShellApplication {
    name = "hosts-job";
    runtimeInputs = [ ];
    text = ''
      while read -r OLD NEW REF
      do
          if [[ "$REF" = "refs/heads/main" ]]
          then
              echo "Ref $REF received. TODO: Trigger job with $NEW"
          else
              echo "Test: $REF $OLD $NEW"
          fi
      done
      exit 0
    '';
  };
in
{
  options.ryzst.int.git.server = {
    enable = mkEnableOption "Internal Git service";
    enableGitAnnex = mkEnableOption "enable git-annex for repos";
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

    networking.firewall.extraCommands = ''
      ${pkgs.nftables}/bin/nft add rule ip6 filter nixos-fw iifname "wg0" counter ip6 saddr { ${clientsIps} } tcp dport ${builtins.toString cfg.port} jump nixos-fw-accept
    '';

    programs.git = {
      enable = true;
      config = {
        init = {
          defaultBranch = "main";
        };
      };
    };

    ryzst.int.git.server.enableGitAnnex = true;

    services.declarative-gitolite = {
      enable = true;
      inherit (cfg) enableGitAnnex;
      user = "git";
      repos = {
        "users/CREATOR/..*" = {
          access = [
            # TODO: build users list
            { perms = "C"; refex = ""; users = [ "man" ]; }
            { perms = "RW+CDM"; refex = ""; users = [ "CREATOR" ]; }
          ];
        };
        "domain" = {
          access = [
            { perms = "RW+CDM"; refex = ""; users = admins; }
            { perms = "R"; refex = ""; users = hosts; }
            #{ perms = "RW"; refex = "hosts"; users = builders; }
          ];
          options = {
            "hook.post-receive" = "hosts-job";
          };
        };
      };
      hooks = {
        repo-specific = [
          {
            name = "hosts-job";
            path = "${hosts-job}/bin/hosts-job";
          }
        ];
      };
      rc = {
        ENABLE = [
          #COMMANDS
          "help"
          "desc"
          "info"
          "writable"
          "D"
          #FEATURES
          "ssh-authkeys"
          "git-config"
          "repo-specific-hooks"
        ];
      };
      userKeys = userKeys // hostKeys;
    };
  };
}
