{ lib, ... }: {
  networking = {
    nameservers = [
      "8.8.8.8"
    ];
    defaultGateway = "207.154.224.1";
    defaultGateway6 = "";
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address = "207.154.227.51"; prefixLength = 20; }
          { address = "10.19.0.5"; prefixLength = 16; }
        ];
        ipv6.addresses = [
          { address = "fe80::a87c:bcff:fe8b:1b92"; prefixLength = 64; }
        ];
        ipv4.routes = [{ address = "207.154.224.1"; prefixLength = 32; }];
        ipv6.routes = [{ address = ""; prefixLength = 128; }];
      };

    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="aa:7c:bc:8b:1b:92", NAME="eth0"
    ATTR{address}=="82:66:fa:5b:b9:45", NAME="eth1"
  '';
}
