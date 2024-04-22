# export fenix toolchain as its own package set
{
  inputs,
  cell,
}: let
  inherit (inputs) fenix;
  inherit (fenix.packages) combine latest targets;

  target-triple = "x86_64-unknown-none";

  target = targets.${target-triple}.latest;
in {
  inherit target-triple;
  toolchain = combine (
    builtins.attrValues {inherit (target) rust-std;}
    ++ builtins.attrValues {inherit (latest) cargo rustc rustfmt;}
    ++ [fenix.packages.rust-analyzer]
  );
}
# # add rust-analyzer from nightly, if not present
# if rustPkgs ? rust-analyzer
# then rustPkgs
# else
#   rustPkgs
#   // {
#     inherit (fenix.packages) rust-analyzer;
#     toolchain = fenix.packages.combine [
#       (builtins.attrValues rustPkgs)
#       fenix.packages.rust-analyzer
#       nixpkgs.cargo-nextest
#     ];
#   }

