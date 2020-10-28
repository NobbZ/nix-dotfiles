{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";

  outputs = { self, nixpkgs }: {
    devShell.x86_64-linux = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
      pkgs.mkShell {
        name = "nixos-builder";
        buildInputs = [ pkgs.gnumake pkgs.nixpkgs-fmt ];
      };

    nixosModules = import ./modules;

    nixosConfigurations = {
      tux-nixos = nixpkgs.lib.nixosSystem (import ./hosts/tux-nixos.nix { inherit self nixpkgs; });
      nixos = nixpkgs.lib.nixosSystem (import ./hosts/nixos.nix { inherit self nixpkgs; });
    };
  };
}
