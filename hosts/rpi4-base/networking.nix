{ hostname, ... }:
{ lib, ... }:
{
  networking = {
    hostName = hostname;
    useNetworkd = true;
    firewall = {
      allowedTCPPorts = [
        53 # unbound
      ];
      allowedUDPPorts = [
        53 # unbound
        5353 # mDNS
      ];
    };

    resolvconf = {
      enable = true;
      useLocalResolver = true;
    };

    wireless = {
      enable = lib.mkForce false;
      # Use iwd instead of wpa_supplicant. It has a user friendly CLI
      iwd = {
        enable = false;
        settings = {
          Network = {
            EnableIPv6 = true;
            RoutePriorityOffset = 300;
          };
          Settings.AutoConnect = true;
        };
      };
    };
  };
}
