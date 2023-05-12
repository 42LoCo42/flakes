{
  description = ''
    A tool to make it easy to stream wayland windows and screens
    to Xwayland applicatons that don't have native pipewire support
  '';

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        kpipewire-custom = pkgs.libsForQt5.kpipewire.overrideAttrs (old: {
          src = pkgs.fetchgit {
            url = "https://invent.kde.org/plasma/kpipewire";
            rev = "31b24a4cfc021d7f077499dc8af71b4a22b51ffc";
            hash = "sha256-ML1MYNWph/EXgou7Jn3tSfp6m1C32oIRi9Fi4AXQNIg=";
          };
        });
      in
      {
        defaultPackage = pkgs.stdenv.mkDerivation rec {
          pname = "xwaylandvideobridge";
          version = "4a72e7c19884c5a87a2cbfcf01c5293199196e1e";
          src = pkgs.fetchgit {
            url = "https://invent.kde.org/system/xwaylandvideobridge";
            rev = version;
            hash = "sha256-tkLvKZ52bbcHrTSEciSlTv5UVncJsnFW7IoWWiTsols=";
          };
          nativeBuildInputs = with pkgs; [
            cmake
            extra-cmake-modules
            kpipewire-custom
            libsForQt5.ki18n
            libsForQt5.knotifications
            libsForQt5.kwidgetsaddons
            libsForQt5.kwindowsystem
            libsForQt5.qt5.qtx11extras.dev
            libsForQt5.wrapQtAppsHook
          ];
          configurePhase = ''
            cmake -DCMAKE_INSTALL_PREFIX="$out" -B build .
          '';
          buildPhase = ''
            cd build
            make
          '';
        };
      });
}
