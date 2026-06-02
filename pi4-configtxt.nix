{
  config,
  pkgs,
  lib,
  ...
}:
{
  hardware.raspberry-pi.config = {
    all = {

      # Base DTB parameters
      # https://github.com/raspberrypi/linux/blob/a1d3defcca200077e1e382fe049ca613d16efd2b/arch/arm/boot/dts/overlays/README#L132
      base-dt-params = {
        dt-overlays = {
          # Enable DRM VC4 V3D driver
          vc4-kms-v3d = {
            enable = true;
            params = { };
          };
          # TODO: find out how to do these
          # disable-wifi = {
          #   enable = true;
          # };
          # disable-bt = {
          #   enable = true;
          # };
        };
      };

    };
  };
}
