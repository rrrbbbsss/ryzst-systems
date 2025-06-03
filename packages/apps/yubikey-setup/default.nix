{ writeShellApplication
, fzf
, yubikey-manager
, gnused
, openssh
, pam_u2f
}:
writeShellApplication {
  name = "yubikey-setup";
  runtimeInputs = [
    fzf
    yubikey-manager
    gnused
    openssh
    pam_u2f
  ];
  text = builtins.readFile ./script.sh;
}
