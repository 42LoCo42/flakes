{
  description = "Plugin for certbot for a DNS-01 challenge with a DuckDNS domain";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python311;
        pyenv = python.withPackages (ps: with ps; [
          certbot
          dnspython
        ]);
      in
      {
        defaultPackage = python.pkgs.buildPythonApplication rec {
          pname = "certbot_dns_duckdns";
          version = "1.3";
          src = pkgs.fetchFromGitHub {
            owner = "infinityofspace";
            repo = pname;
            rev = "v${version}";
            hash = "sha256-G7GtFs3e7L8uKQgvoCy64kh7wzDpz6LCG2tEcsdHcQs=";
          };
          doCheck = false;
          buildInputs = [
            pyenv
          ];
        };
      });
}
