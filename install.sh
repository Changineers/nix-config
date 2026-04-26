#!/usr/bin/env bash
#
# Bootstrap a fresh Ubuntu/Debian box into NixOS with the dev config.
#
# Usage (SSH'd in as root):
#   curl -fsSL https://raw.githubusercontent.com/Changineers/nix-config/main/install.sh | bash

set -euo pipefail

REPO_URL="https://github.com/Changineers/nix-config.git"
CONFIG_DIR="/etc/nixos-config"

# Stage 1: nixos-infect (skipped if already on NixOS)
if ! command -v nixos-rebuild &>/dev/null; then
  echo "==> Converting host to NixOS via nixos-infect"
  echo "    This will reboot. SSH back in and re-run this script."
  read -rp "    Continue? [y/N] " confirm </dev/tty
  [[ "$confirm" =~ ^[yY]$ ]] || exit 1

  curl -fsSL https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | \
    NO_SWAP=y NIX_CHANNEL=nixos-25.11 bash -x 2>&1 | tee /tmp/infect.log
  exit 0
fi

# Stage 2: clone config and apply
echo "==> Cloning config to $CONFIG_DIR"

# Trust the repo dir even if owned by another user (root after infect, dev now).
git config --global --add safe.directory "$CONFIG_DIR" 2>/dev/null || \
  nix-shell -p git --run "git config --global --add safe.directory '$CONFIG_DIR'"

if [[ ! -d "$CONFIG_DIR" ]]; then
  sudo nix-shell -p git --run "git clone '$REPO_URL' '$CONFIG_DIR'"
else
  sudo nix-shell -p git --run "git -C '$CONFIG_DIR' pull --ff-only"
fi

# Place hardware-configuration.nix from infect's output
HW_SRC="/etc/nixos/hardware-configuration.nix"
HW_DST="$CONFIG_DIR/hardware-configuration.nix"
if [[ -f "$HW_SRC" && ! -f "$HW_DST" ]]; then
  sudo cp "$HW_SRC" "$HW_DST"
fi

# Stage it locally so the flake can see it (it's gitignored)
sudo nix-shell -p git --run "git -C '$CONFIG_DIR' add -f hardware-configuration.nix"

echo "==> Applying configuration"
sudo nixos-rebuild switch --flake "$CONFIG_DIR#dev"

# Tailscale is the only path in once the firewall closes port 22.
# Skip if already up (re-runs of install.sh shouldn't re-auth).
if ! sudo tailscale status &>/dev/null; then
  echo "==> Bringing up Tailscale (visit the URL it prints to authenticate)"
  sudo tailscale up --ssh
fi

cat <<EOF

==> Done. From your tailnet:
  ssh dev@$(hostname)

EOF
