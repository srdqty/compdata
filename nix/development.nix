{ compiler ? import ./ghc.nix }:

let
  pkgs = import ./nixpkgs-pinned {};

  hlib = pkgs.haskell.lib;

  withTestAndBench = drv: hlib.doCheck (hlib.doBenchmark drv);

  haskellPackages = pkgs.haskell.packages."${compiler}".override {
    overrides = new: old: {
      compdata = withTestAndBench (new.callPackage ./.. { });
    };
  };
in
  haskellPackages.compdata.env.overrideAttrs (old: rec {
    name = compiler + "-" + old.name;

    buildInputs = [
      pkgs.git
      pkgs.vim
      pkgs.ncurses # Needed by the bash-prompt.sh script
      pkgs.haskellPackages.cabal-install
    ];

    shellHook = old.shellHook + builtins.readFile ./bash-prompt.sh + ''
      source ${pkgs.git.out}/etc/bash_completion.d/git-prompt.sh
      source ${pkgs.git.out}/etc/bash_completion.d/git-completion.bash
    '';
  })
