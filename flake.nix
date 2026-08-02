{
  description = "lesspipe plus";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      packageFor =
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.callPackage ./nix/package.nix { };
    in
    {
      packages = forAllSystems (system: {
        default = packageFor system;
        lesspipe = packageFor system;
      });

      overlays.default = final: _previous: {
        lesspipe = final.callPackage ./nix/package.nix { };
      };

      checks = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          package = packageFor system;
        in
        {
          inherit package;

          shellcheck =
            pkgs.runCommand "lesspipe-plus-shellcheck"
              {
                nativeBuildInputs = [ pkgs.shellcheck ];
              }
              ''
                shellcheck ${./lesspipe.sh} ${./tests/colorizer-path.sh}
                touch "$out"
              '';

          colorizerPath =
            pkgs.runCommand "lesspipe-plus-colorizer-path"
              {
                nativeBuildInputs = [
                  pkgs.bash
                  pkgs.coreutils
                  pkgs.less
                  pkgs.ncurses
                ];
              }
              ''
                ${./tests/colorizer-path.sh} ${package}/bin/lesspipe.sh
                touch "$out"
              '';
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.bash
              pkgs.file
              pkgs.less
              pkgs.shellcheck
              (packageFor system)
            ];
          };
        }
      );

      formatter = forAllSystems (system: (import nixpkgs { inherit system; }).nixfmt);
    };
}
