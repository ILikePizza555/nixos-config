# Goals

The goal behind the design and structure is to create composable configuration modules which can be used to rapidly create host cofigurations. 

# Directory Structure

`hosts/` - Contains configuration for specific hosts. These are generally referenced by `flake.nix` in the `nixosConfigurations` output.
`profiles/` - Declarative configuration.
`keys/` - Per-user public keys
`users/` - Home-manager configs
