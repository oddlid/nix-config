{ pkgs, ... }:
{
  environment = {
    shells = [ pkgs.zsh ];
    systemPackages = with pkgs; [
      btop
      coreutils-full
      curl
      file
      git
      htop
      jq
      lsof
      mosh
      neovim-unwrapped
      nmap
      openssl
      psmisc
      rsync
      tmux
      wget
      zsh
    ];
  };
}
