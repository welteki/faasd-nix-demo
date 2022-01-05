{ inputs, ... }:
{
  imports = [ inputs.faasd.nixosModules.faasd ];

  services.faasd = {
    enable = true;
  };
}
