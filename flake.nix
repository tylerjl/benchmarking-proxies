{
  inputs = {
    devshell.url    = "github:numtide/devshell";
    nixos-shell.url = "github:Mic92/nixos-shell";
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixos-shell, nixpkgs, flake-utils, ... }@inputs:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ inputs.devshell.overlay ];
        };
      in with pkgs; rec {
        devShell = devshell.mkShell {
          commands = [{
            command = "ssh -F ssh_config root@bench";
            name = "connect";
          } {
            command = "nixos-shell --flake '.'";
            help = "Run a VM with the NixOS configuration";
            name = "vm";
          }];
          env = [{
            name = "QEMU_NET_OPTS";
            value = "hostfwd=tcp::8080-:8080,hostfwd=tcp::8081-:8081,hostfwd=tcp::2222-:22";
          }];
          packages = [
            awscli2 caddy darkhttpd gnuplot k6 nixos-shell nginx rs terraform wrk2
            (lighttpd.override {
              enableMagnet = true;
            })
          ];
        };
        packages.static-html = pkgs.buildEnv {
          name = "static-html";
          paths = [ ./static ];
        };
      })) // (let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in {
        overlays.default = prev: final: {
          static-html = self.packages.${system}.static-html;
        };
        nixosConfigurations = {
          aws-bench = nixpkgs.lib.nixosSystem {
            inherit pkgs system;
            modules = [
              "${nixpkgs}/nixos/modules/virtualisation/amazon-image.nix"
              (import ./base.nix)
              (import ./bench.nix)
            ];
          };
          aws-driver = nixpkgs.lib.nixosSystem {
            inherit pkgs system;
            modules = [
              "${nixpkgs}/nixos/modules/virtualisation/amazon-image.nix"
              (import ./base.nix)
              (import ./driver.nix)
            ];
          };
          vm = nixpkgs.lib.makeOverridable nixpkgs.lib.nixosSystem {
            inherit pkgs system;
            modules = [
              nixos-shell.nixosModules.nixos-shell
              (import ./base.nix)
              (import ./bench.nix)
              (import ./driver.nix)
              ({ ... }: {
                config.services.getty.autologinUser = nixpkgs.lib.mkDefault "root";
                config.nixos-shell.mounts.mountHome = false;
                config.nixos-shell.mounts.mountNixProfile = false;
              })
            ];
          };
        };
      });
}
