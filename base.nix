{ pkgs, ... }: let
  sshKey = builtins.readFile ./ssh_pubkey;
in {
  # Perf testing tweaks
  boot.kernel.sysctl = {
    "net.ipv4.ip_local_port_range" = "1024 65535";
    "net.ipv4.tcp_tw_reuse"        = 1;
    "net.ipv4.tcp_timestamps"      = 1;
  };
  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "250000";
  }];
  system.stateVersion = "22.05";
  users.users.root.openssh.authorizedKeys.keys = [ sshKey ];
}
