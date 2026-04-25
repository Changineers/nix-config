# nix-config

Bare-minimum NixOS dev box: docker, tailscale, git, mise.

## Setup

```bash
# On a fresh Ubuntu box, SSH'd in as root:
curl -fsSL https://raw.githubusercontent.com/Changineers/nix-config/main/install.sh | bash
# Reboots into NixOS. SSH back in, re-run the same command.
```

After:
```bash
sudo tailscale up --ssh
```

## Edit and rebuild

```bash
cd /etc/nixos-config
git pull   # or edit locally
sudo nixos-rebuild switch --flake .#dev
```

## TODO before first apply

- Replace SSH key in `configuration.nix`
