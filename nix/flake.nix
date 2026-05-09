{
  description = "Ben's nix-managed user packages, applied alongside Guix Home";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    claude-desktop-debian.url = "github:aaddrick/claude-desktop-debian";
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, claude-desktop-debian, nixgl }:
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
      # Three workarounds stack to get Resolve running on Guix + Framework 16:
      # - nixGLIntel injects the host Mesa stack into Resolve's FHS bwrap so
      #   Qt can create a GLX context (the bundled Mesa has no DRI driver).
      # - HSA_OVERRIDE spoofs the 780M (gfx1103) as gfx1100 because gfx1103
      #   isn't on Resolve's supported list.
      # - OCL_ICD_VENDORS points at nixpkgs' clr ICD; Guix's amdocl64.icd
      #   lives in /gnu/store, which the bwrap doesn't bind in.
      nixGLIntel = nixgl.packages.${system}.nixGLIntel;
      davinci-resolve = pkgs.symlinkJoin {
        name = "davinci-resolve-wrapped-${pkgs.davinci-resolve.version}";
        paths = [ pkgs.davinci-resolve ];
        postBuild = ''
          rm $out/bin/davinci-resolve
          cat > $out/bin/davinci-resolve <<EOF
          #!${pkgs.runtimeShell}
          export HSA_OVERRIDE_GFX_VERSION=11.0.0
          export OCL_ICD_VENDORS=${pkgs.rocmPackages.clr.icd}/etc/OpenCL/vendors
          exec ${nixGLIntel}/bin/nixGLIntel ${pkgs.davinci-resolve}/bin/davinci-resolve "\$@"
          EOF
          chmod +x $out/bin/davinci-resolve
        '';
        inherit (pkgs.davinci-resolve) meta;
      };
    in {
      packages.${system}.default = pkgs.buildEnv {
        name = "guix-config-nix-profile";
        paths = (with pkgs; [
          mise
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
          davinci-resolve
        ];
      };
    };
}
