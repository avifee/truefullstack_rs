/*
This file holds configuration data for repo dotfiles.

Q: Why not just put the put the file there?

A:
 (1) dotfile proliferation
 (2) have all the things in one place / format
 (3) potentially share / re-use configuration data - keeping it in sync
*/
{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std;
  inherit (inputs.std.lib.dev) mkNixago;
  lib = nixpkgs.lib // std.lib // builtins;
in {
  # Tool Homepage: https://editorconfig.org/
  # editorconfig = {
  #   # see defaults at https://github.com/divnix/std/blob/5ce7c9411337af3cb299bc9b6cc0dc88f4c1ee0e/src/data/configs/editorconfig.nix
  #   # data = {};
  # };

  cargo = mkNixago {
    output = ".cargo/config.toml";
    format = "toml";
    data.build = {
      rustflags = ["-Clink-args=-nostdlib"];
      target = cell.pkgs.target-triple;
    };
  };

  # Tool Homepage: https://numtide.github.io/treefmt/
  treefmt = mkNixago lib.cfg.treefmt {
    # see defaults at https://github.com/divnix/std/blob/5ce7c9411337af3cb299bc9b6cc0dc88f4c1ee0e/src/data/configs/treefmt.nix
    devshell.startup.prettier-plugin-toml = inputs.nixpkgs.lib.stringsWithDeps.noDepEntry ''
      export NODE_PATH=${inputs.nixpkgs.nodePackages.prettier-plugin-toml}/lib/node_modules:''${NODE_PATH-}
    '';
    data = {
      formatter = {
        rustfmt = {
          command = "rustfmt";
          options = ["--edition" "2021"];
          includes = ["*.rs"];
        };
        nix = {
          command = lib.getExe nixpkgs.alejandra;
          includes = ["*.nix"];
        };
        prettier = {
          command = lib.getExe nixpkgs.nodePackages.prettier;
          options = ["--plugin" "${nixpkgs.nodePackages.prettier-plugin-toml}/lib/node_modules/prettier-plugin-toml/lib/index.js" "--write"];
          includes = [
            "*.css"
            "*.html"
            "*.js"
            "*.json"
            "*.jsx"
            "*.md"
            "*.mdx"
            "*.scss"
            "*.ts"
            "*.yaml"
            "*.toml"
          ];
        };
        shell = {
          command = lib.getExe nixpkgs.shfmt;
          options = ["-i" "2" "-s" "-w"];
          includes = ["*.sh"];
        };
      };
    };
    packages = with nixpkgs; [
      nodePackages.prettier
      shfmt
    ];
  };

  conform =
    mkNixago lib.cfg.conform
    {
      data = {
        # inherit (inputs) cells;
        commit = {
          header = {length = 89;};
          conventional = {
            # Only allow these types of conventional commits (inspired by Angular)
            types = [
              "build"
              "chore"
              "ci"
              "docs"
              "feat"
              "fix"
              "perf"
              "refactor"
              "style"
              "test"
            ];
          };
        };
      };
    };

  # Tool Homepage: https://github.com/evilmartians/lefthook
  lefthook =
    mkNixago lib.cfg.lefthook
    {
      # see defaults at https://github.com/divnix/std/blob/5ce7c9411337af3cb299bc9b6cc0dc88f4c1ee0e/src/data/configs/lefthook.nix
      data = {
        commit-msg = {
          commands = {
            # Runs conform on commit-msg hook to ensure commit messages are
            # compliant.
            conform = {
              run = "${nixpkgs.conform}/bin/conform enforce --commit-msg-file {1}";
            };
          };
        };
        pre-commit = {
          commands = {
            # Runs treefmt on pre-commit hook to ensure checked-in source code is
            # properly formatted.
            treefmt = {
              run = "${nixpkgs.treefmt}/bin/treefmt {staged_files}";
            };
          };
        };
      };
    };
  # githubsettings = (mkNixago lib.cfg.githubsettings) {
  #   # see defaults at https://github.com/divnix/std/blob/5ce7c9411337af3cb299bc9b6cc0dc88f4c1ee0e/src/data/configs/githubsettings.nix
  #   data = {
  #     repository = {
  #       name = "CONFIGURE-ME";
  #       inherit (import (inputs.self + /flake.nix)) description;
  #       homepage = "CONFIGURE-ME";
  #       topics = "CONFIGURE-ME";
  #       default_branch = "main";
  #       allow_squash_merge = false;
  #       allow_merge_commit = false;
  #       allow_rebase_merge = true;
  #       delete_branch_on_merge = true;
  #       private = true;
  #       has_issues = false;
  #       has_projects = false;
  #       has_wiki = false;
  #       has_downloads = false;
  #     };
  #   };
  # };
  # Tool Homepage: https://rust-lang.github.io/mdBook/
  # mdbook = (mkNixago lib.cfg.mdbook) {
  #   # see defaults at https://github.com/divnix/std/blob/5ce7c9411337af3cb299bc9b6cc0dc88f4c1ee0e/src/data/configs/mdbook.nix
  #   data = {
  #     book.title = "CONFIGURE-ME";
  #     preprocessor.paisano-preprocessor = {
  #       multi = [
  #         {
  #           chapter = "Cell: repo";
  #           cell = "repo";
  #         }
  #       ];
  #     };
  #   };
  # };
}
