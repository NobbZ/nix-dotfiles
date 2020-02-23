{ config, lib, pkgs, ... }:

let cfg = config.languages.nix;

in {
  options.languages.nix = {
    enable = lib.mkEnableOption "Enable support for the nix language";
  };

  config =
    lib.mkIf cfg.enable { programs.emacs.extraPackages = ep: [ ep.nix-mode ]; };
}