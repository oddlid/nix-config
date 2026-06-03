{ hostname, ... }:
{ ... }:
{
  networking = {
    hostName = hostname;
    useNetworkd = true;
    firewall = {
      allowedUDPPorts = [ 5353 ]; # mDNS
    };
    wireless = {
      enable = false;
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
