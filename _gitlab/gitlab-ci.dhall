let EnvVars : Type = https://github.com/dhall-lang/dhall-lang/raw/v16.0.0/Prelude/Map/Type Text Text
let EnvVar : Type = https://github.com/dhall-lang/dhall-lang/raw/v16.0.0/Prelude/Map/Entry Text Text
let emptyEnv : EnvVars = https://github.com/dhall-lang/dhall-lang/raw/v16.0.0/Prelude/Map/empty Text Text
let envVar : ∀(k : Text) -> ∀(v : Text) -> EnvVar = https://github.com/dhall-lang/dhall-lang/raw/v16.0.0/Prelude/Map/keyValue Text

let Stage : Type = < check | build >

let Job : Type = {
    image : Text,
    script : List Text,
    stage : Stage,
    before_script : List Text,
    extends : Optional Text,
    variables : EnvVars
}

let defaultJob : Job = {
stage = Stage.check,
image = "nixos/nix",
script = [] : List Text,
before_script = []: List Text,
extends = None Text,
variables = emptyEnv}

let stages : List Stage = [ Stage.check, Stage.build ]

let nixfmt : Job = defaultJob //
      { stage = Stage.check
      , image = "nixos/nix"
      , script =
        [ "nix run nixpkgs.findutils nixpkgs.nixfmt -c find -name '*.nix' -type f -exec nixfmt --check '{}' \\;"
        ]
      }

let dhall : Job = defaultJob //
      { stage = Stage.check
      , image = "nixos/nix"
      , before_script = [ "nix-env -iA nixpkgs.dhall-json nixpkgs.diffutils" ]
      , script =
        [ "dhall-to-yaml < \$(pwd)/_gitlab/gitlab-ci.dhall | diff \$(pwd)/.gitlab-ci.yml -"
        ]
      }

let buildTemplate : Job = defaultJob //
      { stage = Stage.build
      , image = "nixos/nix"
      , before_script =
        [ "export NIX_HOME=\"\${HOME}/.config/nixpkgs\""
        , "nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs"
        , "nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager"
        , "nix-channel --update"
        , "nix-shell '<home-manager>' -A install"
        , "rm \${NIX_HOME}/home.nix"
        , "ln -s \$(pwd)/home.nix \${NIX_HOME}/home.nix"
        , "ln -s \$(pwd)/hosts/\${SUT}.nix \$(pwd)/hosts/default.nix"
        , "ln -s \${SECRETS_NIX} \$(pwd)/secrets.nix"
        ]
      , script = [ "home-manager build" ]
      }

let buildFor = λ(name : Text) → (defaultJob // {
variables = [ envVar "SUT" name ] , extends = Some ".build" }) : Job

in  { stages = stages
    , `check:nixfmt` = nixfmt
    , `check:dhall` = dhall
    , `.build` = buildTemplate
    , `build:nixos` = buildFor "nixos"
    , `build:delly-nixos` = buildFor "delly-nixos"
    , `build:tux-nixos` = buildFor "tux-nixos"
    }
