{
  description = "Library for handling a lot of the ExpidusOS specific functionality";

  nixConfig = rec {
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
    substituters = [ "https://cache.nixos.org" "https://cache.garnix.io" ];
    trusted-substituters = substituters;
    fallback = true;
    http2 = false;
  };

  inputs.expidus-sdk.url = github:ExpidusOS/sdk/refactor;

  outputs = { self, expidus-sdk }:
    with expidus-sdk.lib;
    flake-utils.simpleFlake {
      inherit self;
      nixpkgs = expidus-sdk;
      name = "expidus";
      overlay = import ./overlay.nix { inherit self; };
      shell = import ./shell.nix { inherit self; };
    };
}
