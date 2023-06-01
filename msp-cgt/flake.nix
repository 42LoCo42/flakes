{
  description = "MSP430 code generation tools - compiler";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      version = "21.6.1";
    in
    {
      packages.${system} = rec {
        installer = pkgs.stdenv.mkDerivation rec {
          pname = "msp-cgt-installer";
          inherit version;

          src = pkgs.fetchurl {
            url = "https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-p4jWEYpR8n/21.6.1.LTS/ti_cgt_msp430_21.6.1.LTS_linux-x64_installer.bin";
            hash = "sha256-Ja/V3T1MxWDR76UcLUkqUIVIgt42YDejIpHbEfHFd94=";
          };
          sourceRoot = ".";

          unpackPhase = ":";
          installPhase = ''
            install -Dm755 ${src} $out/bin/installer
            patchelf --set-interpreter \
              "$(< "$NIX_CC/nix-support/dynamic-linker")" \
              $out/bin/installer
          '';
          dontFixup = true;
        };

        default = pkgs.stdenv.mkDerivation {
          pname = "msp-cgt";
          inherit version;

          src = ./.;

          installPhase = ''
            ${installer}/bin/installer --mode unattended --prefix $out
            dir="$(echo "$out/"*)"
            mv "$dir/"* "$out/"
            rmdir "$dir"
            rm "$out/"*"_uninstaller."{dat,run}
          '';
        };
      };
    };
}
