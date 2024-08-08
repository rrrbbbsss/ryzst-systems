{ rustPlatform
, fetchFromGitHub
, lib
}:
let
  pname = "efmt";
  version = "0.15.0";
in
rustPlatform.buildRustPackage {
  inherit pname version;
  src = fetchFromGitHub {
    owner = "sile";
    repo = "efmt";
    rev = version;
    hash = "sha256-pVwOxJxWcOrzz/h8fj0SMCB84VQ1nKg7ZQ+FHA/EucE=";
  };
  cargoHash = "sha256-k0kpwdszFmGm5CFdgzzFro+7gM68WaxPvPBn1KYcDl0=";

  meta = with lib; {
    description = "An Erlang code formatter.";
    homepage = "https://github.com/sile/efmt";
    license = with licenses; [ mit asl20 ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "efmt";
  };
}
