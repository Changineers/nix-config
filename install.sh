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

nixos-rebuild switch \
  --flake github:Changineers/nix-config#dev \
  --impure

cat <<'EOF'

==> Done. Next:
  sudo tailscale up --ssh
  ssh dev@<ip>

EOF
