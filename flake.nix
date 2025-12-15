{
  outputs =
    { ... }:
    {
      mkTTSModule =
        {
          pkgs,
          package,
          extraDevTools ? [ ],
        }:
        {
          nixpkgs = pkgs;

          packages.default = package;
          devShell = pkgs.mkShell {
            inputsFrom = [ package ];
            buildInputs =
              extraDevTools
              ++ (with pkgs; [
                rustfmt
                clippy
              ]);

            RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
          };

          dockerImage = pkgs.dockerTools.buildLayeredImage {
            name = package.name;
            tag = "latest-${pkgs.stdenv.system}";

            config.Cmd = [ (pkgs.lib.getExe package) ];
          };
        };
    };
}
