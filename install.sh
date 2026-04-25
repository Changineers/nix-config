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
if [[ ! -d "$CONFIG_DIR" ]]; then
  nix-shell -p git --run "git clone '$REPO_URL' '$CONFIG_DIR'"
else
  nix-shell -p git --run "git -C '$CONFIG_DIR' pull --ff-only"
fi

HW_SRC="/etc/nixos/hardware-configuration.nix"
HW_DST="$CONFIG_DIR/hardware-configuration.nix"
if [[ -f "$HW_SRC" && ! -f "$HW_DST" ]]; then
  cp "$HW_SRC" "$HW_DST"
fi

echo "==> Building and applying config"
cd "$CONFIG_DIR"
nix-shell -p git --run "git add -f hardware-configuration.nix"
nix-shell -p git --run "nixos-rebuild switch --flake .#dev"

cat <<'EOF'

==> Done. Next:
  sudo tailscale up --ssh
  ssh dev@<ip>

EOF
