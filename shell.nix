let
  pkgs = import <nixpkgs> {
    overlays = import ./nix;
    config = { };
  };

  inherit (pkgs) niv lefthook dhall-json;
in pkgs.mkShell { buildInputs = [ niv lefthook dhall-json ]; }
