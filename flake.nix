{
  description = "ExpidusOS library";

  inputs = {
    nixpkgs.url = "github:ExpidusOS/nixpkgs/feat/flutter-3-26-pre";
    systems.url = "github:nix-systems/default-linux";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, systems, flake-utils }@inputs:
    flake-utils.lib.eachSystem (import systems) (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            flutter326
            pkg-config
            gtk3
            gtk-layer-shell
            yq
            gdb
          ];
        };
      });
}
