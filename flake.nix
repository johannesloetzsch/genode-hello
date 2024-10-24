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
        packages.${system}.default = genodeEnv.mkDerivation {
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
    };
}