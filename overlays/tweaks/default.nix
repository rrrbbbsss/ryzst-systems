self:
final: prev:
let
  nixpkgs = { rev, hash }:
    import
      (prev.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        inherit rev hash;
      })
      {
        inherit (prev) config;
        crossSystem = prev.hostPlatform.system;
        localSystem = prev.buildPlatform.system;
      };
in
{
  # update nix to 2.28.4
  # (flying a bit blind so not sure if this has fix)
  inherit (nixpkgs {
    rev = "5d0aa4675f7a35ec9661325d1dc22dfcbba5d040";
    hash = "sha256-+Opp9j30rNQyuR5QOHSchJHU6pJJELy9+Olg1uMEYZo=";
  }) nix;

  # fix cross-compilation
  boxes = prev.boxes.overrideAttrs (old: {
    postPatch = ''
      substituteInPlace src/Makefile \
        --replace "STRIP=true" "STRIP=false"
    '';
  });

  # fix cross-compilation
  yubikey-manager = prev.yubikey-manager.overrideAttrs (old: {
    postInstall = ''
      installManPage man/ykman.1
    '' + prev.lib.optionalString (prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform) ''
      installShellCompletion --cmd ykman \
        --bash <(_YKMAN_COMPLETE=bash_source "$out/bin/ykman") \
        --zsh  <(_YKMAN_COMPLETE=zsh_source  "$out/bin/ykman") \
        --fish <(_YKMAN_COMPLETE=fish_source "$out/bin/ykman") \
    '';
  });

  # use /etc/pam_p11/<username> instead of home dir
  pam_p11 = prev.pam_p11.overrideAttrs (old: {
    patches = old.patches or [ ] ++ [ ./pam_p11.patch ];
  });
}
