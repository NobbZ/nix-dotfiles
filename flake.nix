{
  inputs = {
    nixpkgs2009.url = "github:nixos/nixpkgs/nixos-20.09";
    nixpkgsUnstable.url = "github:nixos/nixpkgs/nixos-unstable";
    homeManager.url = "github:nix-community/home-manager";
    emacsOverlay.url = "github:nix-community/emacs-overlay";
    mozillaOverlay = {
      url = "github:mozilla/nixpkgs-mozilla";
      flake = false;
    };
  };

  outputs = { self, nixpkgs2009, nixpkgsUnstable, homeManager, emacsOverlay, mozillaOverlay }:
    let
      pkgs = import nixpkgsUnstable {
        overlays = self.overlays;
        config = { };
        system = "x86_64-linux";
      };

      hm = (import homeManager { inherit pkgs; }).home-manager;
    in
    {
      overlays = [
        emacsOverlay.overlay
        (import mozillaOverlay)
      ];

      devShell.x86_64-linux = pkgs.mkShell {
        name = "home-manager-shell";

        NIX_PATH = "nixpkgs=${pkgs}"; #:nixos=${nixpkgs2009}:home-manager=${hm}";

        HOME_MANAGER_CONFIG = "./home.nix";
      };
    };
}
