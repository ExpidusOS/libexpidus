{ self }:
{ pkgs }:
with pkgs;
with lib;
let
  overlay = (import ./overlay.nix { inherit self; } pkgs pkgs);
  pkg = overlay.expidus.libexpidus;
in
mkShell rec {
  inherit (pkg) name pname version mesonFlags;

  packages = with pkgs; [
    emscripten
    gdb valgrind lcov
  ] ++ pkg.buildInputs ++ pkg.nativeBuildInputs;
}
