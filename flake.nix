{
  description = "A very basic flake for Rust development";

  inputs = {
    fenix.url = "github:nix-community/fenix";
    nixpkgs = {
      url = "github:NixOS/nixpkgs";
      follows = "fenix/nixpkgs";
    };
    std = {
      url = "github:divnix/std";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        devshell.url = "github:numtide/devshell";
        nixago = {
          url = "github:jmgilman/nixago";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs @ {
    self,
    std,
    flake-utils,
    nixpkgs,
    ...
  }: let
    lib = nixpkgs.lib // flake-utils.lib // builtins;
  in
    std.growOn {
      inherit inputs;
      systems = lib.defaultSystems;
      cellsFrom = ./nix;
      cellBlocks = with std.blockTypes; [
        (installables "packages")
        # Contribution Environment
        (devshells "shells")
        (pkgs "rust")
        (nixago "configs")
      ];
    } {
      devShells = std.harvest self ["repo" "shells"];
      packages = std.harvest self ["repo" "packages"];
    }
    // lib.eachDefaultSystem (system: {formatter = nixpkgs.legacyPackages.${system}.alejandra;});

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
