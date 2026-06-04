{ pkgs, lib, ... }:
{
  environment = {
    etc = {
      "resolv.conf".text = lib.mkForce "nameserver 127.0.0.1";
    };

    shells = [
      pkgs.bash
      pkgs.zsh
    ];

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
