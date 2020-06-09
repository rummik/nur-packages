# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  hm = home-manager;
  home-manager = hmModules;
  hmModules.modules = import ./home-manager;

  dptf = pkgs.callPackage ./pkgs/dptf {
    stdenv = pkgs.gcc7Stdenv;
  };

  dptfxtract = pkgs.callPackage ./pkgs/dptfxtract {};

  immersed-vr = pkgs.callPackage ./pkgs/immersed-vr {};

  nbfc = pkgs.callPackage ./pkgs/nbfc {};
  parsec-gaming = pkgs.callPackage ./pkgs/parsec-gaming {};
}
