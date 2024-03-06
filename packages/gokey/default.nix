{ buildGoModule
, fetchFromGitHub
, lib
}:
let
  pname = "gokey";
  version = "202400223";
in
buildGoModule {
  inherit pname version;
  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "gokey";
    rev = "26fcef24d123e0eaf7b92224e6880f529f94aa9f";
    sha256 = "sha256-nt4fO8NKYfRkpoC1z8zDrEZC7+fo6sU/ZOHCMHIAT58=";
  };
  vendorHash = "sha256-ZDCoRE2oP8ANsu7jfLm3BMLzXdsq1dhsEigvwWgKk54=";

  meta = with lib; {
    description = "A simple vaultless password manager in Go";
    homepage = "https://github.com/cloudflare/gokey";
    license = licenses.bsd3;
  };
}
