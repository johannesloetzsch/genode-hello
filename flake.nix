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

      genode_hello = genodeEnv.mkDerivation {
        name = "hello.iso";

        repos = [
          ./.
        ];

        buildInputs = with genode-utils.packages.${system}; [
          grub2
          nova
        ];

        buildPhase = ''
          make run/hello
        '';

        installPhase = ''
          cp var/run/hello.iso $out
        '';
      };

      genode_bash = genodeEnv.mkDerivation {
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
          make run/bash
        '';

        installPhase = ''
          cp var/run/bash.iso $out
        '';
      };

      genode_python = genodeEnv.mkDerivation {
        name = "python.iso";

        repos = [
          ./.
        ];

        buildInputs = with genode-utils.packages.${system}; [
          grub2
          nova
          jitterentropy libc
        ] ++ (with pkgs; [
          git
          zip
        ]);

        buildPhase = ''
          #USER=j03
          #cd $GENODE_DIR/repos/gems/sculpt/depot/
          #mkdir $USER
          #cp ~/.gnupg/pubkey.asc USER/pubkey
          #echo 'http://johannesloetzsch.de' > download
          #cd -

          [ -d $GENODE_DIR/repos/world ] || git clone https://github.com/genodelabs/genode-world.git $GENODE_DIR/repos/world
          $GENODE_DIR/tool/ports/prepare_port python3
          $GENODE_DIR/tool/depot/create $USER/pkg/x86_64/python3 UPDATE_VERSIONS=1  ## FORCE=1 REBUILD= -j4
          ls $GENODE_DIR/depot/$USER/pkg/python3
          $GENODE_DIR/tool/depot/publish $USER/pkg/x86_64/python3/2025-05-11 XZ_THREADS=4
          #ls $GENODE_DIR/public/$USER

          #vim $GENODE_DIR/depot/$USER/index/25.04
          #$GENODE_DIR/tool/depot/publish $USER/index/25.04

        '';

        installPhase = ''
          #cp var/run/python.iso $out
        '';
      };

      #default = genode_bash_hello;
      #genode-pkgs = genode-utils.packages.${system};
    };
  };
}
