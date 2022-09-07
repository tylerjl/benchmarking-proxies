{ lib, pkgs, ... }: let
  caddyDefault = ''
    :8080 {
      handle_path /html {
        root * ${pkgs.static-html}
        file_server
      }

      handle /synthetic {
        respond "Hello, world!"
      }

      handle /proxy {
        reverse_proxy localhost:8081
      }
    }
  '';
  nginxDefault = ''
    events {
        use epoll;
    }

    http {
        access_log off;

        server {
            server_name localhost;
            listen 0.0.0.0:8080;

            location = /html {
                alias ${pkgs.static-html}/index.html;
            }

            location = /synthetic {
                return 200 "Hello, world!";
            }

            location = /proxy {
                proxy_pass http://127.0.0.1:8081;
            }
        }
    }
  '';
  nginxOptimized = ''
    events {
        use epoll;
        worker_connections 1024;
    }

    worker_processes auto;

    http {
        access_log off;
        sendfile on;
        proxy_cache_path /tmp/nginx-cache keys_zone=cache:10m;


        server {
            server_name localhost;
            listen 0.0.0.0:8080;
            proxy_cache cache;

            location = /html {
                alias ${pkgs.static-html}/index.html;
            }

            location = /synthetic {
                return 200 "Hello, world!";
            }

            location = /proxy {
                proxy_pass http://127.0.0.1:8081;
            }
        }
    }
  '';
in {
  environment.systemPackages = with pkgs; [
    psrecord
  ];

  system.activationScripts.pristine = ''
    ${pkgs.systemd}/bin/systemctl stop nginx caddy || true
  '';

  networking.firewall.allowedTCPPorts = [ 8080 ];

  services.caddy = {
    enable = true;
    configFile = pkgs.writeText "Caddyfile" caddyDefault;
  };
  systemd.services.caddy = {
    serviceConfig.LimitNOFILE = "250000:250000";
    wantedBy = lib.mkForce [];
  };

  services.nginx = {
    enable = true;
    logError = "/dev/null";
    config = nginxOptimized;
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
      magnet.attract-physical-path-to = ( "${luaScript}" )
    '';
  };
}
