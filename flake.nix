{
  description = "Arya Elfren Website";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib;
    eachSystem allSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex =
          pkgs.texlive.combine { inherit (pkgs.texlive) scheme-basic latexmk; };
      in rec {
        packages = {
          document = pkgs.stdenvNoCC.mkDerivation rec {
            name = "website-pdf";
            src = self;
            buildInputs = [ pkgs.coreutils tex ];
            phases = [ "unpackPhase" "buildPhase" "installPhase" ];
            buildPhase = ''
              export PATH="${pkgs.lib.makeBinPath buildInputs}";
              mkdir -p .cache/texmf-var
              env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
                latexmk -interaction=nonstopmode -pdf -lualatex \
                AE.tex
            '';
            installPhase = ''
              mkdir -p $out
              cp AE.pdf $out/
            '';
          };
        };
        defaultPackage = packages.document;
      });
}

