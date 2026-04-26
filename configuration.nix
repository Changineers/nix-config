{ config, pkgs, workmux, ... }:

{
  boot.loader.grub.enable = true;

  networking.hostName = "dev";
  networking.useDHCP = true;
  time.timeZone = "Australia/Melbourne";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;  # Claude Code has an unfree license

  environment.systemPackages = with pkgs; [
    claude-code
    git
    home-manager
    mise
    tmux
    workmux.packages.${pkgs.system}.default
  ];

  programs.zsh.enable = true;
  programs.fish.enable = true;

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
