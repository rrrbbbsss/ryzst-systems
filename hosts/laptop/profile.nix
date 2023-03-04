{ config, lib, pkgs, modulesPath, ... }:

{
  security.pam = {
    u2f = {
      enable = true;
      authFile = ../../idm/users/rrrbbbsss/pubkeys/u2f_keys;
      cue = true;
    };
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      swaylock.u2fAuth = true;
      sshd.u2fAuth = false; # todo...
    };
  };
}
