final: prev:
{
  swiProlog = (prev.swiProlog.overrideAttrs
    (old: rec {
      version = "9.1.10";
      src = prev.fetchFromGitHub {
        owner = "SWI-Prolog";
        repo = "swipl-devel";
        rev = "V${version}";
        hash = "sha256-hr9cI0Ww6RfZs99iM1hFVw4sOYZFZWr8Vzv6dognCTQ=";
        fetchSubmodules = true;
      };
    })).override
    {
      openssl = prev.openssl_3;
    };
}
