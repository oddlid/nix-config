{
  nixos-raspberrypi,
  ...
}:
{
  imports = with nixos-raspberrypi.nixosModules; [
    # Hardware configuration
    raspberry-pi-4.base
    raspberry-pi-4.display-vc4
    raspberry-pi-4.bluetooth
    # It seems none of the options in this file works, need to find out why
    # ./pi4-configtxt.nix
  ];
}
