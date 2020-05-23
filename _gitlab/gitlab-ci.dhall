let stages = [ "check", "build" ]

let nixfmt = {
  stage = "check",
  image = "nixos/nix",
  script = [ "nix run nixpkgs.findutils nixpkgs.nixfmt -c find -name '*.nix' -type f -exec nixfmt --check '{}' \\;" ]
}

let buildTemplate = {
  stage = "build",
  image = "nixos/nix",
  before_script = [
    "export NIX_HOME=\"\${HOME}/.config/nixpkgs",
    "nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs",
    "nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager",
    "nix-channel --update",
    "nix-shell '<home-manager>' -A install",
    "rm \${NIX_HOME}/home.nix",
    "ln -s $(pwd)/home.nix \${NIX_HOME}/home.nix",
    "ln -s $(pwd)/hosts/\${SUT}.nix $(pwd)/hosts/default.nix",
    "ln -s \${SECRETS_NIX} $(pwd)/secrets.nix"
  ],
  script = [ "home-manager build" ]
}

let buildFor = \(name : Text) -> {
  variables = { SUT = name },
  extends = ".build"
}

in {
  stages = stages,
  `check:nixfmt` = nixfmt,

  `.build` = buildTemplate,

  `build:nixos` = buildFor "nixos",
  `build:delly-nixos` = buildFor "delly-nixos",
  `build:tux-nixos` = buildFor "tux-nixos"
}
