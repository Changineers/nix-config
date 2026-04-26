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

Reboots into NixOS. SSH back in, re-run the same command — it finishes the install and brings up Tailscale (you'll click the auth URL it prints).

After that, the box is reachable from your tailnet only — public port 22 is closed.

```bash
ssh dev@<hostname>
```
