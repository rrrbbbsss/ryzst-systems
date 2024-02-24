{ lib
, trivialBuild
, fetchFromGitHub
}:

trivialBuild {
  pname = "souffle-ts-mode";
  version = "202400223";

  src = fetchFromGitHub {
    owner = "chaosite";
    repo = "souffle-ts-mode";
    rev = "458ebe6115dbc8c6a60b019326ada7aa6106161a";
    sha256 = "sha256-VCVnCSXTcFvHHsDDk/7NbnORDHwV+cRLk9aagABbXow=";
  };

  meta = {
    homepage = "https://github.com/chaosite/souffle-ts-mode";
    description = "Emacs major mode for Soufflé using tree-sitter";
    license = lib.licenses.gpl3;
  };
}
