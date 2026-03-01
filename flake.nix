{
  outputs =
    { ... }:
    {
      mkTTSModule =
        {
          pkgs,
          package,
          disableFortify ? false,
          extraDevTools ? [ ],
          extraDockerContents ? [ ],
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
            hardeningDisable = pkgs.lib.optionals disableFortify [ "fortify" ];
          };

          dockerImage = pkgs.dockerTools.buildLayeredImage {
            name = package.name;
            tag = "latest-${pkgs.stdenv.system}";

            contents = extraDockerContents;

            config.Cmd = [ (pkgs.lib.getExe package) ];
          };
        };
    };
}
