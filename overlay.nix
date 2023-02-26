{ self }:
final: prev:
with final;
with lib;
rec {
  expidus = prev.expidus.extend (f: p: {
    defaultPackage = f.libexpidus;

    libexpidus = stdenv.mkDerivation {
      pname = "libexpidus";
      version = "git+${self.shortRev or "dirty"}";

      src = cleanSource self;

      nativeBuildInputs = with buildPackages; [
        buildPackages.expidus.sdk
        meson
        ninja
        pkg-config
      ];

      buildInputs = [
        expidus.neutron
      ];

      meta = {
        description = "Library for handling a lot of the ExpidusOS specific functionality";
        homepage = "https://github.com/ExpidusOS/libexpidus";
        license = licenses.gpl3Only;
        maintainers = with maintainers; [ RossComputerGuy ];
      };
    };
  });
}
