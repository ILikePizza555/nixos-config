# Goals

The goal behind the design and structure is to create composable configuration modules which can be used to rapidly create host cofigurations. 

# Directory Structure

`hosts/` - Contains configuration for specific hosts. These are generally referenced by `flake.nix` in the `nixosConfigurations` output.
`modules/` - Common system modules. This are either imported by host nixos configurations or directly in `flake.nix` by the `module` directive.
`keys/` - Per-user public keys
