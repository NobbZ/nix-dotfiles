{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";
  inputs.unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.master.url = "github:nixos/nixpkgs/master";

  inputs.nix.url = "github:nixos/nix/master";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "unstable";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.emacs.url = "github:nix-community/emacs-overlay";
  inputs.emacs.inputs.nixpkgs.follows = "master";

  outputs = { self, nixpkgs, unstable, flake-utils, emacs, ... }@inputs:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      upkgs = unstable.legacyPackages.x86_64-linux;
      epkgs = import inputs.master { system = "x86_64-linux"; overlays = [ self.overlays.emacs ]; };
      nixos = pkgs.recurseIntoAttrs {
        configs = pkgs.dontRecurseIntoAttrs (builtins.mapAttrs
          (_: hostConfig: pkgs.dontRecurseIntoAttrs hostConfig.config.system.build.toplevel)
          self.nixosConfigurations);
      };
      home = pkgs.recurseIntoAttrs {
        configs = pkgs.recurseIntoAttrs (builtins.mapAttrs
          (_: homeConfig: homeConfig.activationPackage)
          self.homeConfigurations);
      };
    in
    {
      devShell.x86_64-linux =
        nixpkgs.legacyPackages.x86_64-linux.callPackage
          ./packages/devShell.nix
          { };

      nixosModules = import ./nixos/modules;
      nixosConfigurations = import ./nixos/hosts inputs;

      homeModules = import ./home/modules pkgs.lib;
      homeConfigurations = {
        tux-nixos = self.lib.mkHomeConfig "nmelzer" ./home/hosts/tux-nixos.nix;
        delly-nixos = self.lib.mkHomeConfig "nmelzer" ./home/hosts/delly-nixos.nix;
        nixos = self.lib.mkHomeConfig "demo" ./home/hosts/nixos.nix;
      };

      overlay = import ./home/nix/myOverlay;

      overlays = {
        inputs = final: prev: { inherit inputs; };
        emacs = emacs.overlay;
        self = self.overlay;
      };

      packages.x86_64-linux = {
        advcp = upkgs.callPackage ./home/packages/advcp { };
        elixir-lsp = upkgs.beam.packages.erlang.callPackage ./home/packages/elixir-lsp {
          rebar3 = pkgs.beam.packages.erlang.rebar3;
        };
        erlang-ls = upkgs.beam.packages.erlang.callPackage ./home/packages/erlang-ls { };
        keyleds = upkgs.callPackage ./home/packages/keyleds {
          stdenv = upkgs.gcc8Stdenv;
        };
        rofi-unicode = upkgs.callPackage ./home/packages/rofi-unicode { };
        dracula-konsole = upkgs.callPackage ./home/packages/dracula/konsole.nix { };
        gnucash-de = upkgs.callPackage ./home/packages/gnucash-de { };
        kmymoney-de = upkgs.callPackage ./home/packages/kmymoney-de { };
        emacs = epkgs.emacsGcc;
      } // (import ./scripts inputs)
      // flake-utils.lib.flattenTree (pkgs.recurseIntoAttrs {
        inherit nixos home;
      });

      lib = import ./lib inputs;

      checks.x86_64-linux = self.packages.x86_64-linux;
      # flake-utils.lib.flattenTree (pkgs.recurseIntoAttrs { inherit nixos; });

      apps.x86_64-linux = {
        build = { type = "app"; program = "${self.packages.x86_64-linux.build-config}/bin/build-config.sh"; };
        switch = { type = "app"; program = "${self.packages.x86_64-linux.switch-config}/bin/switch-config.sh"; };
      };
    };
}
