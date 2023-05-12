{
  description = "A set of SUID tools for mounting 9p filesystems via v9fs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        defaultPackage = pkgs.stdenv.mkDerivation rec {
          pname = "9mount";
          version = "1.3";
          src = pkgs.fetchurl {
            url = "http://sqweek.net/9p/9mount-${version}.tar.gz";
            hash = "sha256-gg2AubR40F7LAirWWEd7N8/CQUqGacOvF9GSpSIGTBc=";
          };

          patchPhase = "patch -p1 < " + ./unpriv.patch;
          installPhase = "make prefix=$out install";
        };
      })) // {
      nixosModules.default = { config, ... }:
        let
          system = config.nixpkgs.system;
          pkg = self.defaultPackage.${system};
          mkWrapper = name: {
            inherit name;
            value = {
              setuid = true;
              owner = "root";
              group = "root";
              source = "${pkg}/bin/${name}";
            };
          };
        in
        {
          security.wrappers = builtins.listToAttrs (map mkWrapper [
            "9mount"
            "9umount"
            "9bind"
          ]);
        };
    };
}
