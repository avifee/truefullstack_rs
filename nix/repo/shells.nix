{
  inputs,
  cell,
}: let
  inherit (inputs.std) std lib;
  inherit (inputs) nixpkgs;

  l = nixpkgs.lib // builtins // lib;

  dev = lib.dev.mkShell {
    packages = builtins.attrValues {inherit (nixpkgs) pkg-config nil cargo-nextest;};
    language.rust = {
      packageSet = cell.pkgs;
      enableDefaultToolchain = true;
      tools = ["rust"];
    };

    devshell.startup.link-cargo-home = {
      deps = [];
      text = ''
        # ensure CARGO_HOME is populated
        mkdir -p "$PRJ_DATA_DIR/cargo"
        ln -snf $(ls -d ${cell.pkgs.rust}/*) "$PRJ_DATA_DIR/cargo"
      '';
    };

    env = [
      {
        # ensures subcommands are picked up from the right place
        # but also needs to be writable; see link-cargo-home above
        name = "CARGO_HOME";
        eval = "$PRJ_DATA_DIR/cargo";
      }
      {
        # ensure we know where rustup_home will be
        name = "RUSTUP_HOME";
        eval = "$PRJ_DATA_DIR/rustup";
      }
      {
        name = "RUST_SRC_PATH";
        # accessing via toolchain doesn't fail if it's not there
        # and rust-analyzer is graceful if it's not set correctly:
        # https://github.com/rust-lang/rust-analyzer/blob/7f1234492e3164f9688027278df7e915bc1d919c/crates/project-model/src/sysroot.rs#L196-L211
        value = "${cell.pkgs.rust}/lib/rustlib/src/rust/library";
      }
    ];
    imports = [
      "${inputs.std.inputs.devshell}/extra/language/rust.nix"
    ];

    nixago = l.attrsets.attrValues cell.configs;

    commands = let
      rustCmds =
        l.map (name: {
          inherit name;
          package = cell.pkgs.rust; # has all bins
          category = "rust dev";
          # fenix doesn't include package descriptions, so pull those out of their equivalents in nixpkgs
          help = nixpkgs.${name}.meta.description;
        }) [
          "rustc"
          "cargo"
          "rustfmt"
          "rust-analyzer"
        ];
    in
      [
        {
          package = nixpkgs.treefmt;
          category = "repo tools";
        }
        {
          package = std.cli.default;
          category = "std";
        }
      ]
      ++ rustCmds;
  };
in {
  inherit dev;
  default = dev;
}
