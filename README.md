# nix-config

Bare-minimum NixOS dev box: docker, tailscale, git, mise, home-manager.

Login shell defaults to zsh. Fish is also available — `chsh -s $(which fish)` to switch.

## Personal config (optional)

Layer your own Home Manager flake on top:

```bash
home-manager switch --flake github:<you>/nix-personal#dev
```

## Setup

On a fresh Ubuntu box, SSH in and run:

```bash
curl -fsSL https://raw.githubusercontent.com/Changineers/nix-config/main/install.sh | bash
```

Reboots into NixOS. SSH back in, re-run the same command to finish the installation.

After:
```bash
sudo tailscale up --ssh
```

## TODO before first apply

- Replace SSH key in `configuration.nix`
