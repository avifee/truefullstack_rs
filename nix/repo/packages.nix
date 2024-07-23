{
  inputs,
  cell,
}: let
  inherit (inputs) std self nixpkgs;
  inherit (cell.pkgs) crane;
in {
  # sane default for a binary package
  default = crane.buildPackage {
    meta.description = "the primary package";
    buildInputs = [nixpkgs.cargo-nextest];
    src = std.incl self [
      "${self}/Cargo.lock"
      "${self}/Cargo.toml"
      "${self}/src"
    ];
    cargoTestCommand = "cargo nextest run --cargo-profile release";
  };
}
