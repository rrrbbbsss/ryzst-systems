{ lib
, rustPlatform
, fetchFromGitLab
}:

rustPlatform.buildRustPackage rec {
  pname = "oniux";
  version = "0.4.0";

  src = fetchFromGitLab {
    owner = "tpo/core";
    repo = pname;
    rev = "v${version}";
    domain = "gitlab.torproject.org";
    sha256 = "sha256-wWB/ch8DB2tO4+NuNDaGv8K4AbV5/MbyY01oRGai86A=";
  };
  useFetchCargoVendor = true;
  cargoHash = "sha256-tUOxs9bTcXS3Gq6cHYe+eAGAEYSRvf3JVGugBImbvJM=";

  meta = with lib; {
    description = "Tool to isolate an arbitrary applicaiton over the Tor network";
    homepage = "https://gitlab.torproject.org/tpo/core/oniux";
    license = [ licenses.mit licenses.asl20 ];
    platforms = platforms.unix;
    mainProgram = "oniux";
  };
}
