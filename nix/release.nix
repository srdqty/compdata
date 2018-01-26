{ compiler ? import ./ghc.nix }:

let
  pkgs = import ./nixpkgs-pinned { };

  haskellPackages = pkgs.haskell.packages."${compiler}".override {
    overrides = new: old: {
      compdata = old.callPackage ./.. { };
    };
  };

  # Specifying ghc packages this way ensures that ghc-pkg can see our packages
  ghcAndPackages = haskellPackages.ghcWithPackages (self : [
    self.compdata
  ]);
in
  pkgs.stdenv.mkDerivation {
    name = "${compiler}-compdata-release";

    buildInputs = [
      pkgs.ncurses # Needed by the bash-prompt.sh script.
      ghcAndPackages
    ];

    shellHook = builtins.readFile ./bash-prompt.sh + ''
      source ${pkgs.git.out}/etc/bash_completion.d/git-prompt.sh
      source ${pkgs.git.out}/etc/bash_completion.d/git-completion.bash
    '';
  }
