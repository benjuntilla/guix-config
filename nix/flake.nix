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
          yazi
          zed-editor
          zellij
        ]) ++ [
          claude-desktop-debian.packages.${system}.default
        ];
      };
    };
}
