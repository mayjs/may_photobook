{
  description = "May Photobook Framework";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    {
      templates.photobook = {
        path = ./.;
        description = "A LaTeX Photobook project";
      };
      templates.default = self.templates.photobook;
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      required_packages = with pkgs; [
        (texlive.combine
          {inherit (pkgs.texlive) scheme-medium photobook varwidth;})
        texlab # LaTeX language server
        python3 # Used for some utility scripts
        jhead # Can auto-rotate images according to exif orientation
        just # To quickly run commands
        epeg # Used to generate preview images
        parallel # Speed up some shell scripts
        podofo # Used to manipulate PDF boxes
        poppler_utils # Used to read PDF boxes
        bash # Used for scripts
        coreutils # Used for env
      ];
    in {
      devShells.default = pkgs.mkShell {
        packages = required_packages;
      };
      packages.photobook = pkgs.stdenv.mkDerivation {
        pname = "photobook";
        version = "2025-03-31";
        src = ./.;
        nativeBuildInputs = required_packages;
        patchPhase = ''
          substituteInPlace ./utils/*.sh ./utils/*.py --replace /usr/bin/env ${pkgs.coreutils}/bin/env
        '';
        buildPhase = ''
          just build
          just strip-pdf-boxes
        '';
        installPhase = ''
          mkdir -p $out
          cp ./*.pdf $out
        '';
      };
      packages.default = self.packages.${system}.photobook;
      checks.shellcheck =
        pkgs.runCommandLocal "shellcheck" {
          src = ./.;
        } ''
          ${pkgs.shellcheck}/bin/shellcheck $src/utils/*.sh
          mkdir $out # Required by 'nix flake check'
        '';
      formatter = pkgs.writeShellApplication {
        name = "Format Project";
        text = ''
          echo "Making scripts executable..."
          chmod +x ./utils/*.sh ./utils/*.py
          echo "Formatting Nix files..."
          ${pkgs.alejandra}/bin/alejandra .
          echo "Formatting LaTeX files..."
          ${pkgs.tex-fmt}/bin/tex-fmt -l 150 -t 4 ./**.sty ./**.tex
          echo "Formatting Python files..."
          ${pkgs.black}/bin/black "./utils"
          echo "Formatting Bash files..."
          ${pkgs.shfmt}/bin/shfmt -w ./utils/*.sh
        '';
      };
    });
}
