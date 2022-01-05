{
  description = "faasd-nix demo";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
    welteki-nix.url = "github:welteki/welteki.nix";

    nixos-shell.url = "github:welteki/nixos-shell/improve-flake-support";
    nixos-shell.inputs.nixpkgs.follows = "nixpkgs";

    faasd.url = "github:welteki/faasd-nix";
  };

  outputs = { self, nixpkgs, welteki-nix, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {

      nixosConfigurations.faasd-demo = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          welteki-nix.nixosModules.common
          welteki-nix.nixosModules.welteki-users
          welteki-nix.nixosModules.auto-fix-vscode-server

          # Configuration for digitalocean droplet.
          ./faasd-demo/networking.nix
          ./faasd-demo/hardware-configuration.nix

          ({ pkgs, ... }: {
            nix = {
              package = pkgs.nix_2_4;
              extraOptions = ''
                experimental-features = nix-command flakes
              '';
            };

            zramSwap.enable = true;

            services.auto-fix-vscode-server.enable = true;

            networking.hostName = "faasd-demo";
            networking.domain = "welteki.dev";
          })
        ];
      };

      nixosConfigurations.faasd-vm = inputs.nixos-shell.lib.nixosShellSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./faasd-module.nix

          (args: {
            nixos-shell.mounts.mountHome = false;
            virtualisation.memorySize = 1024;
          })
        ];
      };

      devShell.${system} =
        let
          nixos-shell = inputs.nixos-shell.defaultPackage.${system};
        in
        pkgs.mkShell {
          buildInputs = [
            nixos-shell
            pkgs.faas-cli
            pkgs.nixpkgs-fmt
            pkgs.rnix-lsp
          ];
        };
    };
}
