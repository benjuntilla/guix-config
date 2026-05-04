{
  description = "Ben's nix-managed user packages, applied alongside Guix Home";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    claude-desktop-debian.url = "github:aaddrick/claude-desktop-debian";
  };

  outputs = { self, nixpkgs, claude-desktop-debian }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      worktrunk = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "worktrunk";
        version = "0.47.0";
        src = pkgs.fetchurl {
          url = "https://github.com/max-sixty/worktrunk/releases/download/v${version}/worktrunk-x86_64-unknown-linux-musl.tar.xz";
          sha256 = "126e38a1bffbc26694fe36ece29e50cd107f4806f9d4ff76c1a5ae8ebad44130";
        };
        installPhase = ''
          runHook preInstall
          install -Dm755 wt $out/bin/wt
          install -Dm755 git-wt $out/bin/git-wt
          runHook postInstall
        '';
        meta.mainProgram = "wt";
      };
    in {
      packages.${system}.default = pkgs.buildEnv {
        name = "guix-config-nix-profile";
        paths = (with pkgs; [
          anki
          bluebubbles
          cryptomator
          gopass
          insomnia
          lazygit
          nix-ld
          obsidian
          r2modman
          ruff
          vhs
          yazi
          zed-editor
          zellij
        ]) ++ [
          claude-desktop-debian.packages.${system}.default
          worktrunk
        ];
      };
    };
}
