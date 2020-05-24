let
  pkgs = import <nixpkgs> {
    overlays = import ./nix;
    config = { };
  };

  inherit (pkgs) niv lefthook dhall dhall-json;
in pkgs.mkShell { buildInputs = [ niv lefthook dhall dhall-json ]; }
