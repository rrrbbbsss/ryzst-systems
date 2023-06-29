{ lib, runCommandLocal, makeWrapper, bash, fzf, yubikey-manager, gnused, openssh, pam_u2f }:
runCommandLocal "yubikey-setup"
{
  script = ./script.sh;
  nativeBuildInputs = [ makeWrapper ];
} ''
  makeWrapper $script $out/bin/yubikey-setup \
  --prefix PATH : ${lib.makeBinPath [ bash fzf yubikey-manager gnused openssh pam_u2f ]}
''
