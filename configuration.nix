{ config, pkgs, ... }:

{
  boot.loader.grub.enable = true;

  networking.hostName = "dev";
  networking.useDHCP = true;
  time.timeZone = "Australia/Melbourne";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;  # Claude Code has an unfree license

  environment.systemPackages = with pkgs; [
    claude-code
    gcc
    gh
    git
    gnumake
    home-manager
    mise
    mosh
    tmux

    (writeShellScriptBin "setup-github-ssh" ''
      set -euo pipefail

      KEY="$HOME/.ssh/id_ed25519"
      REQUIRED_SCOPES="admin:public_key,admin:ssh_signing_key"

      if ! gh auth status -h github.com >/dev/null 2>&1; then
        echo "Not authenticated. Run:" >&2
        echo "  gh auth login -h github.com --scopes '$REQUIRED_SCOPES'" >&2
        exit 1
      fi

      status=$(gh auth status -h github.com 2>&1)
      if ! echo "$status" | grep -q admin:public_key \
         || ! echo "$status" | grep -q admin:ssh_signing_key; then
        echo "Refreshing gh auth with required scopes..."
        gh auth refresh -h github.com -s "$REQUIRED_SCOPES"
      fi

      if [ ! -f "$KEY" ]; then
        echo "Generating ed25519 key at $KEY"
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        ssh-keygen -t ed25519 -f "$KEY" -C "$(whoami)@$(hostname)" -N ""
      else
        echo "Using existing key at $KEY"
      fi

      title="$(hostname)-$(date +%Y%m%d)"
      gh ssh-key add "$KEY.pub" --title "$title" || true
      gh ssh-key add "$KEY.pub" --title "$title-sign" --type signing || true

      if ! ssh-keygen -F github.com >/dev/null 2>&1; then
        echo "Pre-trusting github.com host key..."
        ssh-keyscan -t ed25519 github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
      fi

      echo
      echo "Done. Test with: ssh -T git@github.com"
    '')
  ];

  programs.zsh.enable = true;
  programs.fish.enable = true;

  # Lets non-Nix dynamic binaries (e.g. mise-managed node) find /lib64/ld-linux-*.
  programs.nix-ld.enable = true;

  # SSH access is via Tailscale only — no static authorized keys.
  users.users.dev = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" ];
  };
  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--ssh" ];
  };
  virtualisation.docker.enable = true;

  # Public internet has nothing exposed; SSH reaches us only over tailscale0.
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    checkReversePath = "loose";
  };

  system.stateVersion = "25.11";
}
