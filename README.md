Building a "bash" application at the moment required internet during buildPhase

```sh
nix develop
runPhase unpackPhase && runPhase buildPhase && runPhase installPhase; exit $?
$? && qemu-kvm -machine q35 -m 1G outputs/out/bash.iso
```
