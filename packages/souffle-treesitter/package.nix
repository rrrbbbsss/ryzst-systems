{ tree-sitter, fetchFromGitHub }:

tree-sitter.buildGrammar {
  language = "tree-sitter-souffle";
  version = "20240223";
  src = fetchFromGitHub {
    owner = "chaosite";
    repo = "tree-sitter-souffle";
    rev = "31c6bd7bb6dfe659d7c010e829d7e9ad621a8a6c";
    hash = "sha256-3Remv8jy6/Gf34nimOqStuFzQLgwrx3ddrFFg7xLe+I=";
  };
}
