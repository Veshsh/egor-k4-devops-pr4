{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
      ];
      perSystem =
        {
          self',
          inputs',
          pkgs,
          lib,
          config,
          system,
          ...
        }:
        {
          overlayAttrs = {
            inherit (config.packages) api frontend;
          };

          packages.api = pkgs.buildNpmPackage {
            pname = "time-web-api";
            version = "1.0.0";
            src =
              pkgs.fetchgit {
                url = "https://gitlab.com/reu_courses/time-app-praktica.git";
                sparseCheckout = [
                  "api"
                ];
                hash = "sha256-GztNWf+HELJIHGLw5uRGlbKlx1NGIqJtQ6YuMLI9yto=";
              }
              + "/api";

            npmDepsHash = "sha256-KHwkCSmxNv/oYJTSOfefYrZJUn80bnqG2AobNWsXHh8=";
            dontNpmBuild = true;
          };
          packages.frontend = pkgs.buildNpmPackage {
            pname = "time-web-frontend";
            version = "1.0.0";
            src =
              pkgs.fetchgit {
                url = "https://gitlab.com/reu_courses/time-app-praktica.git";
                sparseCheckout = [
                  "frontend"
                ];
                hash = "sha256-iQaAL/aUv4nxz8C74K3uAhBg2ntZ2XkaGnfLWnllPiY=";
              }
              + "/frontend";

            npmDepsHash = "sha256-89cac/KXuKVhdJ+Vr/I/Isdd6je6GJJBgXI7pH6eaXM=";
            installPhase = ''
              runHook preInstall
              target="$out/srv"
              mkdir -p "$target"
              cp -r ./dist "$target"
              runHook postInstall
            '';
          };

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              arion
              nodejs
            ];
          };

        };
    };

}
