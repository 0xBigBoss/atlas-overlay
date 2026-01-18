# atlas-overlay

Nix flake overlay for [Atlas](https://atlasgo.io) - the official binary distribution from Ariga.

## Why this overlay?

The `atlas` package in nixpkgs builds the community edition from source using `buildGoModule`. The community build excludes Pro/Enterprise features that are gated behind the `ent` build tag:

- Functions and stored procedures
- Triggers
- Row-level security (RLS)
- Views
- `atlas login` command
- Other Pro features

This overlay fetches the official pre-built binary from Ariga which includes all features under the [Atlas EULA](https://ariga.io/legal/atlas/eula).

## Usage

### As a flake input

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    atlas-overlay.url = "github:0xBigBoss/atlas-overlay";
  };

  outputs = { nixpkgs, atlas-overlay, ... }: {
    # Option 1: Use the overlay
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [{
        nixpkgs.overlays = [ atlas-overlay.overlays.default ];
        environment.systemPackages = [ pkgs.atlas ];
      }];
    };

    # Option 2: Use the package directly
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      packages = [ atlas-overlay.packages.x86_64-linux.atlas ];
    };
  };
}
```

### Run directly

```bash
nix run github:0xBigBoss/atlas-overlay -- version
```

### Development shell

```bash
nix develop github:0xBigBoss/atlas-overlay
atlas version
```

## Supported platforms

- `x86_64-linux`
- `x86_64-darwin`
- `aarch64-darwin`

## License

The overlay code in this repository is MIT licensed.

The Atlas binary itself is distributed under the [Atlas EULA](https://ariga.io/legal/atlas/eula). By using this overlay, you agree to the Atlas EULA terms.

## Version

Current Atlas version: **v1.0.0**
