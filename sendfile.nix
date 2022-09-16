{ pkgs, ... }: {
  services.caddy = {
    package = pkgs.caddySendfile;
  };
}
