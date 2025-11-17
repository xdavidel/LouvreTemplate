{
  description = "A flake for Wayland compositor based on Louvre";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    self,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
      ];

      flake = {
      };

      perSystem = {
        config,
        pkgs,
        ...
      }: let
        inherit (pkgs) callPackage;
        louvre-example = callPackage ./default.nix {};
        shellOverride = old: {
          nativeBuildInputs =
            old.nativeBuildInputs
            ++ [
            ];
          buildInputs = old.buildInputs ++ [];
        };
      in {
        packages.default = louvre-example;
        overlayAttrs = {
          inherit (config.packages) louvre-example;
        };
        packages = {
          inherit louvre-example;
        };
        devShells.default = louvre-example.overrideAttrs shellOverride;
        formatter = pkgs.alejandra;
      };
      systems = [
        "x86_64-linux"
        "i686-linux"
        "aarch64-linux"
      ];
    };
}
