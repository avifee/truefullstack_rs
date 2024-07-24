{
  inputs,
  cell,
}: let
  inherit (inputs) std self;

  crane = inputs.crane.lib.overrideToolchain cell.pkgs.rust;
in {
  # sane default for a binary package
  default = crane.buildPackage {
    meta.description = "the primary package";
    src = std.incl self [
      "${self}/.cargo/config.toml"
      "${self}/Cargo.lock"
      "${self}/Cargo.toml"
      "${self}/src"
    ];
    doCheck = false; # can't test anyways
    cargoExtraArgs = "--target ${cell.pkgs.target-triple}";
  };
}
