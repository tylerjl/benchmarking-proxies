{ lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    psrecord
    static-html
  ];

  system.activationScripts = {
    pristine = ''
      ${pkgs.systemd}/bin/systemctl stop nginx caddy || true
    '';
  };

  systemd.services.static-html = {
    wantedBy = [ "nginx.service" "caddy.service" ];
    script = ''
      ln -sf ${pkgs.static-html} /srv/static
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];

  services.caddy = {
    enable = true;
    configFile = ./Caddyfile;
  };
  systemd.services.caddy = {
    serviceConfig.LimitNOFILE = "250000:250000";
    wantedBy = lib.mkForce [];
  };

  services.nginx = {
    enable = true;
    logError = "/dev/null";
    config = builtins.readFile ./nginx.conf;
  };
  systemd.services.nginx = {
    serviceConfig.LimitNOFILE = "250000:250000";
    wantedBy = lib.mkForce [];
  };

  services.lighttpd = let
    luaScript = ./synthetic.lua;
  in {
    enable = true;
    port = 8081;
    enableModules = [ "mod_magnet" ];
    document-root = "${pkgs.static-html}";
    extraConfig = ''
      magnet.attract-raw-url-to = ( "${luaScript}" )
    '';
  };
}
