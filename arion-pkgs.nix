let
  flake = builtins.getFlake (toString ./.);
in
import flake.inputs.nixpkgs {
  system = "x86_64-linux";
  overlays = [ flake.overlays.default ];
}
