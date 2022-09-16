{ pkgs, ... }: {
  services.caddy = {
    package = pkgs.caddyNoMetrics;
  };
}
