{
  description = "Arya Elfren silva";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib;
    eachSystem allSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        devPkgs = with pkgs; [
          git
        ];
      in rec {
        packages = {
          document = pkgs.stdenvNoCC.mkDerivation rec {
            name = "Arya Elfren silva";
            src = self;
            buildInputs = with pkgs; [
              coreutils
              soupault
              pandoc # .md support
              git # `last edited` support
            ];
            phases = [ "unpackPhase" "buildPhase" "installPhase" ];
            buildPhase = ''
              soupault
            '';
            installPhase = ''
              mkdir -p $out
              cp -r build/* $out/
            '';
          };
        };
        defaultPackage = packages.document;
        overlays.default = final: prev: {
          blogpkgs = outputs.packages.${prev.system};
        };
        devShell = pkgs.mkShell {
          nativeBuildInputs = devPkgs;
        };
      });
}

