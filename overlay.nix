{ self }:
final: prev:
with final;
with lib;
rec {
  expidus = prev.expidus.extend (f: p: {
    defaultPackage = f.libexpidus;

    libexpidus = p.libexpidus.mkPackage {
      rev = self.shortRev or "dirty";
      src = cleanSource self;
    };
  });
}
