{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    k6
  ];
}
