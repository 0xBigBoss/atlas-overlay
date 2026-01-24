{
  description = "Atlas database migration tool - official binary (unfree, requires allowUnfree)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: let
    sources = builtins.fromJSON (builtins.readFile ./sources.json);
    version = sources.version;
    systems = builtins.attrNames sources.platforms;

    outputs = flake-utils.lib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      source = sources.platforms.${system};

      atlas = pkgs.stdenv.mkDerivation {
        pname = "atlas";
        inherit version;

        src = pkgs.fetchurl {
          url = source.url;
          sha256 = source.sha256;
        };

        # Skip phases not needed for pre-built binary
        dontUnpack = true;
        dontBuild = true;
        dontConfigure = true;

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          cp $src $out/bin/atlas
          chmod +x $out/bin/atlas
          runHook postInstall
        '';

        meta = with pkgs.lib; {
          description = "Atlas - declarative database schema migration tool";
          homepage = "https://atlasgo.io";
          license = licenses.unfree; # Atlas EULA
          platforms = builtins.attrNames sources.platforms;
          mainProgram = "atlas";
        };
      };
    in {
      packages = {
        inherit atlas;
        default = atlas;
      };

      apps = {
        atlas = flake-utils.lib.mkApp {
          drv = atlas;
          name = "atlas";
        };
        default = flake-utils.lib.mkApp {
          drv = atlas;
          name = "atlas";
        };
      };

      devShells.default = pkgs.mkShell {
        packages = [atlas];
      };
    });
  in
    outputs
    // {
      overlays.default = final: prev: {
        atlas = outputs.packages.${prev.system}.atlas;
      };
    };
}
