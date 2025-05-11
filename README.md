Examples of building systems based on the Genode OS Framework using [Nix](https://nixos.org/) [Flakes](https://nixos.wiki/wiki/flakes).

The tooling is based on the work of [https://github.com/zgzollers/nixpkgs-genode](https://github.com/zgzollers/nixpkgs-genode).
This repo was created using the [Flake template](https://github.com/zgzollers/nixpkgs-genode?tab=readme-ov-file#flake-template):
```sh
nix flake new -t github:zgzollers/nixpkgs-genode#genode ./genode-hello
```

To see a list of available examples, use:
```sh
nix flake show
```


## hello

The "hello" application and runscript from the [Genode Foundations book](https://genode.org/documentation/genode-foundations/23.05/index.html)

```sh
nix build .#genode_hello
qemu-system-x86_64 -cdrom result -m 64 -nographic  ## press Ctrl+A X to quit qemu
```

* `nix build .#genode_hello` builds the nix-derivation `genode_hello` defined in `flake.nix`
  * the derivation (package) is stored in the `nix-store` (`/nix/store/`) and consists of a single file `hello.iso`
  * when `nix build […]` finishes successfully, it creates a symlink `result` in the current directory
    * see `ls -l result`
    * the iso can be booted by `qemu-system-x86_64 -cdrom result […]`
    * press **Ctrl+A X** to quit qemu

Using `nix build` we have been able to define a **reproducible build**. The build is pure functional (free of side effects). This is enforced by running it in a sandbox.
All dependencies are used in the versions guaranteed by `flake.lock`.


## bash

> Building a "bash" application at the moment requires internet during buildPhase

Using genodes `prepare_port` in the `buildPhase` tries to download sources. This side effect however violates the constraints of nix to guarantee reproducible builds. Trying to build with `nix build .#genode_bash` fails.

If we are willing to rely on genodes `prepare_port`, there is a workaround: We can use `nix develop` instead of `nix build`.

```sh
nix develop .#genode_bash
runPhase unpackPhase && runPhase buildPhase && runPhase installPhase; exit $?
qemu-kvm -machine q35 -m 1G outputs/out/bash.iso
```

* `nix develop .#genode_bash` opens an **interactive development shell** with all build dependencies defined for the package
  * while `nix build` runs in a sandbox, `nix develop` gives us full control to debug/build in an impure environment
  * the shell function `runPhase` can be used to trigger `unpackPhase`, `buildPhase` and `installPhase` from the package definition
  * once the build is finished, the resulting iso can be found in `outputs/out/bash.iso` and can be used with `qemu-kvm`
