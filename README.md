# Goals

The goal behind the design and structure is to create composable configuration modules which can be used to rapidly create host cofigurations. 

# Directory Structure

- `hosts/` - Contains configuration for specific hosts. These are generally referenced by `flake.nix` in the `nixosConfigurations` output.
- `profiles/` - Declarative configuration.
- `keys/` - Per-user public keys
- `users/` - Home-manager configs

# Note (mostly to myself) on Code Formatting

Use tabs for indent. Nix config files tend to be indent-heavy, and using tabs allows you to modify the indent size without changing the source itself. This is a useful feature when you're editing on several devices of varying screen sizes. 

Yes, sometimes Vim inserts spaces for some reason (still looking into this), sometimes I accidentally add spaces, and these errors are never obvious when they occur.

In this case, configure the *editor* to show you the indent characters! Vim has `listchars`, VSCode has extensions for this.