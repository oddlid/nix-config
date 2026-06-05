{ primaryUser, ... }:
{ lib, ... }:
{
  services = {
    getty.autologinUser = lib.mkForce primaryUser;

    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    resolved = {
      enable = false;
    };

    syncthing = {
      enable = false; # might be needed later
    };

    tailscale = {
      enable = true;
      extraDaemonFlags = [
        "--socks5-server=:1080"
        "--outbound-http-proxy-listen=:1081"
      ];
      extraSetFlags = [
        "--advertise-exit-node"
        "--ssh"
      ];
      openFirewall = true;
      useRoutingFeatures = "both";
    };

    udev.extraRules = ''
      # Ignore partitions with "Required Partition" GPT partition attribute
      # On our RPis this is firmware (/boot/firmware) partition
      ENV{ID_PART_ENTRY_SCHEME}=="gpt", \
        ENV{ID_PART_ENTRY_FLAGS}=="0x1", \
        ENV{UDISKS_IGNORE}="1"
    '';

    unbound = {
      enable = true;
      localControlSocketPath = "/run/unbound/unbound.ctl";
      settings = {
        server = {
          # We need to unset this in order for overridden local adrs to work
          auto-trust-anchor-file = lib.mkForce ''""'';
          interface = [
            "0.0.0.0"
            "::0"
          ];
          prefer-ip6 = true;

          # All *-slabs should inherit the value of num-threads
          num-threads = 4;
          # msg-cache-slabs = 4;
          # rrset-cache-slabs = 4;
          # infra-cache-slabs = 4;
          # key-cache-slabs = 4;
          rrset-cache-size = "512m";
          msg-cache-size = "256m";
          outgoing-range = 8192;
          num-queries-per-thread = 4096;
          so-rcvbuf = "4m";
          so-sndbuf = "4m";
          so-reuseport = true;
          prefetch = true;
          prefetch-key = true;

          extended-statistics = true;
          access-control = [
            "127.0.0.0/8 allow"
            "192.168.0.0/16 allow"
            "172.16.0.0/12 allow"
            "10.0.0.0/8 allow"
            "100.64.0.0/10 allow"
            "2001:9b1:26ff:ce::/56 allow"
            "fd7a:115c:a1e0::/48 allow"
          ];
          private-domain = "oddware.net";
          # TODO: decide if I want local records here, as well as in AGH
        };
        forward-zone = [
          {
            # Use AGH as upstream for split horizon
            name = "oddware.net";
            forward-addr = "10.66.6.6";
          }
          {
            name = "ts.net";
            forward-addr = "100.100.100.100";
          }
          {
            name = ".";
            forward-tls-upstream = true;
            forward-addr = [
              "2a07:e340::4@853#base.dns.mullvad.net"
              "86.54.11.13#noads.joindns4.eu"
              "2a13:1001::86:54:11:13#noads.joindns4.eu"
              "86.54.11.213#noads.joindns4.eu"
              "2a13:1001::86:54:11:213#noads.joindns4.eu"
            ];
          }
        ];
        remote-control.control-enable = true;
      };
    };
  };
}
