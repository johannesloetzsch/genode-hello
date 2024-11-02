{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";

    genode-utils = {
      url = "github:zgzollers/nixpkgs-genode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, genode-utils, flake-compat }:
  let
    inherit (genode-utils.packages.${system}) genodeEnv;

    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

  in {
    packages.${system} = rec {
      default = genode_bash_hello;

      genode_bash_hello = genodeEnv.mkDerivation {
        name = "bash.iso";

        repos = [
          ./.
        ];

        buildInputs = with genode-utils.packages.${system}; [
          grub2
          nova

          bash
            jitterentropy libc linux x86emu

        ] ++ (with pkgs; [
          mawk
          gperf
          autoconf
        ]);

        buildPhase = ''
          $GENODE_DIR/tool/ports/prepare_port coreutils ncurses stb ttf-bitstream-vera vim

          make app/hello
          make run/bash
        '';

        installPhase = ''
          cp var/run/bash.iso $out
        '';
      };

      genode-pkgs = genode-utils.packages.${system};
    };
  };
}
