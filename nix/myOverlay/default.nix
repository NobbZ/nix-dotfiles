self: super:

{
  advcp = super.callPackage (import ./advcp) { };
  asdf-vm = super.callPackage (import ./asdf) { };
  aur-tools = super.callPackage (import ./aur) { };
  direnv-nix = super.callPackage (import ./direnv-nix) { };
  elixir-lsp = super.callPackage (import ./elixir-lsp) { };
  erlang-ls = super.callPackage (import ./erlang-ls) { };
  keyleds = super.callPackage (import ./keyleds) { };

  nobbzLib = (import ./lib);
}
