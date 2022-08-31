### https://nixos.org/channels/nixos-22.05 nixos

{ modulesPath, ... }:
{
  imports = [ "$${modulesPath}/virtualisation/amazon-image.nix" ];

  users.users.root.openssh.authorizedKeys.keys = [
    "${deploy-key}"
  ];
}
