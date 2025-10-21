{
  pkgs,
  ...
}:
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # Think I want to just have the bare minimum shell tools here, and solve
  # the rest with home-manager.
  environment.systemPackages = with pkgs; [
    # asn
    btop
    coreutils-full
    devenv
    duf
    dust
    ghostscript
    git
    hcloud
    imagemagick
    mc
    mosh
    nixfmt
    nodejs_24 # Common for a lot of nvim stuff, so might just always have it
    rclone
    statix
    tree-sitter
    vim
    zsh
  ];
}
