{ pkgs, ... }:
rec {
  programs.gpg = {
    enable = true;
    package = pkgs.gnupg;
    # publicKeys = [ { source = ./pubkeys.txt; trust = ultimate } ];
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
}
