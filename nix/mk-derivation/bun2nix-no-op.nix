{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) mkOption types;
in
{
  options.perSystem = mkPerSystemOption {
    options.mkDerivation.bun2nixNoOp = mkOption {
      description = ''
        `bun2nix` builds run the post-install script
        for their repos by default.

        However, the actual `bun2nix` binary is 
        unsuitable to be ran inside the nix sandbox,
        hence this package provides a no-op script with
        the same name to replace it.
      '';
      type = types.package;
    };
  };

  config.perSystem =
    { pkgs, ... }:
    {
      # PATCHED (zbranchio fork for norris): the upstream no-op uses `writeShellApplication { text = "";
      # }`, whose shellcheck pass fails with SC2148 (no shebang) on Linux builders (CI), blocking the
      # workspace build. `writeShellScriptBin` produces the same no-op `bun2nix` binary with NO
      # shellcheck. Upstream 2.1.0 (latest tag) still has text="".
      mkDerivation.bun2nixNoOp = pkgs.writeShellScriptBin "bun2nix" "";
    };
}
