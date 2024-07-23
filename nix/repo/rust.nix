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
    # rust-src and rust-std are just there to suppress rust-analyzer errors about
    # them missing in the sysroot, we're not actually using them and I can't
    # be arsed to find another way to make it shut up
    builtins.attrValues {inherit (target) rust-std;}
    ++ builtins.attrValues {inherit (latest) cargo rustc rustfmt rust-src clippy;}
  );
}
