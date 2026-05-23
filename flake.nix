{
  description = "Flake for development workflows.";

  inputs = {
    rainix.url = "github:rainprotocol/rainix";
    rain.url = "github:rainlanguage/rain.cli";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      flake-utils,
      rainix,
      rain,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = rainix.pkgs.${system};
      in
      rec {
        packages = {
          st0x-prelude = rainix.mkTask.${system} {
            name = "st0x-prelude";
            body = ''
              set -euxo pipefail

              mkdir -p meta;
              forge script --silent ./script/BuildAuthoringMeta.sol;
              rain meta build \
                -i <(cat ./meta/ERC4626SubParserAuthoringMeta.rain.meta) \
                -m authoring-meta-v2 \
                -t cbor \
                -e deflate \
                -l none \
                -o meta/St0xWords.rain.meta \
                ;
            '';
          };
        }
        // rainix.packages.${system};

        devShells.default = pkgs.mkShell {
          packages = [
            packages.st0x-prelude
            rain.defaultPackage.${system}
          ];

          inherit (rainix.devShells.${system}.default) shellHook buildInputs nativeBuildInputs;
        };
      }
    );

}
