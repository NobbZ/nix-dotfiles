{ config, lib, pkgs, ... }:

let
  emacsEnabled = config.programs.emacs.enable;
  cfg = config.programs.emacs;
  beaconEnabled = cfg.packages.beacon.enable;

  bool2Lisp = b: if b then "t" else "nil";

  lisps = lib.attrsets.mapAttrs' (k: v: {
    name = ".emacs.d/lisp/${k}.el";
    value = {
      text = pkgs.nobbzLib.emacs.generatePackage k v.tag v.comments v.requires
        v.code;
    };
  }) cfg.localPackages;

  lispRequires = let
    names = lib.attrsets.mapAttrsToList (n: _: n) cfg.localPackages;
    sorted = builtins.sort (l: r: l < r) names;
    required = builtins.map (r: "(require '${r})") sorted;
  in builtins.concatStringsSep "\n" required;

in {
  imports = [ ./beacon.nix ./polymode ./whichkey ];

  options.programs.emacs = {
    splashScreen = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enable the startup screen.
      '';
    };

    localPackages = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({ name, config, ... }: {
        options = {
          tag = lib.mkOption { type = lib.types.str; };
          comments = lib.mkOption { type = lib.types.listOf lib.types.str; };
          requires = lib.mkOption { type = lib.types.listOf lib.types.str; };
          code = lib.mkOption { type = lib.types.str; };
        };
      }));
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra preferences to add to <filename>init.el</filename>.
      '';
    };

    module = lib.mkOption {
      description = "Attribute set of modules to link into emacs configuration";
      default = { };
    };
  };

  config = lib.mkIf emacsEnabled {
    programs.emacs.extraConfig = ''
      ;; adjust the load-path to find further down required files
      (add-to-list 'load-path
                   (expand-file-name "lisp" user-emacs-directory))

      ;; require all those local packages
      ${lispRequires}

      ;; set splash screen
      (setq inhibit-startup-screen ${bool2Lisp (!cfg.splashScreen)})

      ;; company
      (setq tab-always-indent 'complete)
      (add-to-list 'completion-styles 'initials t)

      ;; (eval-when-compile (require 'company))

      (add-hook 'after-init-hook 'global-company-mode)
      (with-eval-after-load 'company
        ;; (diminish 'company-mode "CMP")
        (define-key company-mode-map   (kbd "M-+") '("complete"       . 'company-complete))
        (define-key company-active-map (kbd "M-+") '("change backend" . 'company-other-backend))
        (define-key company-active-map (kbd "C-n") '("next"           . 'company-select-next))
        (define-key company-active-map (kbd "C-p") '("previous"       . 'company-select-previous))
        (setq-default company-dabbrev-other-buffers 'all
                      company-tooltip-align-annotations t))
    '';

    programs.emacs.extraPackages = ep: [ ep.company ];

    home.file = {
      ".emacs.d/init.el" = {
        text = pkgs.nobbzLib.emacs.generatePackage "init"
          "Initialises emacs configuration" [ ] [ ] cfg.extraConfig;
      };
    } // lisps;
  };
}