{ pkgs, ... }:
rec {
  programs.gpg = {
    enable = true;
    package = pkgs.gnupg;
    publicKeys = [{ source = ../../pubkeys/gpg.pub; trust = "ultimate"; }];
    scdaemonSettings = {
      disable-ccid = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
    defaultCacheTtl = 1800;
    defaultCacheTtlSsh = 1800;
    pinentryFlavor = "curses";
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Match host * exec "${programs.gpg.package}/bin/gpg-connect-agent --quiet updatestartuptty /bye >/dev/null 2>&1"
    '';
  };

  # weirdness on fresh new systems: have to look at card status before gpg can be used...
  systemd.user.services.gpg-card = {
    Unit = {
      Description = "gpg check card";
      Requires = "gpg-agent.socket";
      After = "gpg-agent.socket";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${programs.gpg.package}/bin/gpg --card-status";
      RemainAfterExit = "yes";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
