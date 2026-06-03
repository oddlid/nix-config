{ primaryUser, ... }:
{ pkgs, ... }:
let
  groups = [
    "wheel"
    "networkmanager"
    "video"
  ];
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+8RJi9manjKv4+ybqYq1zniojiXf21R7fUvGdXCO9P odd-mbp-m1"
  ];
in
{
  users = {
    users = {
      # nixos = {
      #   isNormalUser = true;
      #   extraGroups = groups;
      #   # Allow the graphical user to login without password
      #   initialHashedPassword = "";
      #   openssh.authorizedKeys.keys = keys;
      # };
      root = {
        # Allow the user to log in as root without a password.
        initialHashedPassword = "";
        openssh.authorizedKeys.keys = keys;
        shell = pkgs.zsh;
      };
      ${primaryUser} = {
        isNormalUser = true;
        extraGroups = groups;
        # Allow the graphical user to login without password
        initialHashedPassword = "";
        openssh.authorizedKeys.keys = keys;
        shell = pkgs.zsh;
      };
    };
  };
}
