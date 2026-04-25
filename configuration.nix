{ config, pkgs, ... }:

{
  boot.loader.grub.enable = true;

  networking.hostName = "dev";
  networking.useDHCP = true;
  time.timeZone = "Australia/Melbourne";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git
    mise
  ];

  users.users.dev = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAs/njOaWBWpmv5DitYvP/jFXryBQx9nJmXKrVRpHGlWuvTGcs27DIU/8DkX25W5Z0brOFvr/F7HGyLduVdLTskP3WALb9jT9FQqLZoTIxYddeXC/ke30BiKqlKptMgk1CXrZBd2PEBJRWu29mGG78BCkd5ucUOih3c3i1FGfrZMx9U6tkIA1jKCJuukL1LcZ+KLthmHdKqQBICNk7as+1u8WD4tn09pxkLfDBsHn516r/zdVD9m9LvmCq0k9PAhE5aI+SqTfBGiW7/vVA/4QCyQhX67treOSdSXN6XWhH7Sxvy+Pqvd4beKNSP86D3z90MrrFRMkEA/ABoX6E1LjA8Q== james@jagregory.com"
    ];
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

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    trustedInterfaces = [ "tailscale0" ];
    checkReversePath = "loose";
  };

  system.stateVersion = "25.11";
}
