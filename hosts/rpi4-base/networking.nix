{ hostname, ... }:
{ lib, ... }:
{

  # TODO: Find out how to set IPv6 token for IF end0.
  # This must be done in the overrides for each host, not here.

  networking = {
    hostName = hostname;
    useNetworkd = true;
    # Some services have an option to open the firewall for whatever ports they need (e.g. ssh).
    # Those that don't have such options, must be opened for here.
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
