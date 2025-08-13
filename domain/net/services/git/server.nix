{ config, lib, pkgs, ... }:
with lib;
let
  # TODO: redo and cleanup
  mkAuthorizedKey = key: ip:
    (concatStringsSep "," [
      "cert-authority"
      ''principals="laminar"''
      ''command="${pkgs.gitolite}/bin/gitolite-shell laminar"''
      "restrict"
      "no-port-forwarding"
      "no-X11-forwarding"
      "no-agent-forwarding"
      "no-pty"
      "no-user-rc"
      ''from="${ip}"''
    ]) + " ${key}";
  laminar-Keys =
    attrsets.foldlAttrs
      (acc: n: v: [ (mkAuthorizedKey v.keys.ssh v.ip) ] ++ acc) [ ]
      config.ryzst.int.ci.server.nodes;


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

  # TODO: do this properly.
  hosts-job = pkgs.writeShellApplication {
    name = "hosts-job";
    runtimeInputs = with pkgs; [
      laminar
    ];
    text = ''
      while read -r OLD NEW REF
      do
          if [[ "$REF" = "refs/heads/main" ]]
          then
              laminarc queue hosts-job COMMIT="$NEW"
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

    networking.firewall.extraInputRules = ''
      iifname "wg0" counter ip6 saddr { ${clientsIps} } tcp dport ${builtins.toString cfg.port} accept
    '';

    programs.git = {
      enable = true;
      config = {
        init = {
          defaultBranch = "main";
        };
      };
    };

    # TODO: this is gross
    users.users.git.openssh.authorizedKeys.keys = laminar-Keys;

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
            # ci
            { perms = "R"; refex = "main"; users = [ "laminar" ]; }
            { perms = "RW"; refex = "hosts"; users = [ "laminar" ]; }
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
