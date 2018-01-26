with import ../nixpkgs-pinned {};

stdenv.mkDerivation rec {
  name = "generate-cabal-and-project-nix-file";

  project-root = import ../project-root.nix;

  buildInputs = [
    cabal2nix
  ];

  shellHook = ''
    set -eu

    echo -e "\nRunning cabal2nix to generate default.nix ...\n"
    cabal2nix . > ${project-root}/default.nix

    exit
  '';
}
