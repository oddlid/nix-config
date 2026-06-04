# Config for the lowest parts of the system
{
  config,
  pkgs,
  lib,
  ...
}:
let
  kernelBundle = pkgs.linuxAndFirmware.v6_12_87;
in
{
  # Make swedish kb work by default
  console.keyMap = "sv-latin1";
  i18n.defaultLocale = "sv_SE.UTF-8";

  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [
        "noatime"
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=1min"
      ];
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };
  zramSwap.enable = true;

  boot = {
    loader.raspberry-pi.firmwarePackage = kernelBundle.raspberrypifw;
    kernelPackages = kernelBundle.linuxPackages_rpi4;
    kernelParams = [
      "cgroup_enable=cpuset"
      "cgroup_enable=memory"
      "cgroup_memory=1"
    ];
    kernel.sysctl = {
      "net.core.rmem_max" = 4194304;
      "net.core.wmem_max" = 4194304;
    };
    tmp.useTmpfs = true;
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [
        "oddee"
        "@wheel"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      # Use either this or nh, not both
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = lib.mkAfter [
      (self: super: {
        # This is used in (modulesPath + "/hardware/all-firmware.nix") when at least
        # enableRedistributableFirmware is enabled
        # I know no easier way to override this package
        inherit (kernelBundle) raspberrypiWirelessFirmware;
        # Some derivations want to use it as an input,
        # e.g. raspberrypi-dtbs, omxplayer, sd-image-* modules
        inherit (kernelBundle) raspberrypifw;
      })
    ];
  };

  system = {
    nixos.tags =
      let
        cfg = config.boot.loader.raspberry-pi;
      in
      [
        "raspberry-pi-${cfg.variant}"
        cfg.bootloader
        config.boot.kernelPackages.kernel.version
      ];
    # We are stateless, so just default to latest.
    # stateVersion = config.system.nixos.release;
    stateVersion = "26.05";
  };
}
