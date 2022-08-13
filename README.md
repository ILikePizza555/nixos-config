# Directory Structure

`hosts/` - Contains configuration for specific hosts. These are generally referenced by `flake.nix` in the `nixosConfigurations` output.
`system/` - Common system modules. This are either imported by host nixos configurations or directly in `flake.nix` by the `module` directive.
`keys/` - Per-user public keys
