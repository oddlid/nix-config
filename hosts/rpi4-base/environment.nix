{ pkgs, lib, ... }:
{
  environment = {
    etc = {
      # TODO: When booting the RPI, the HW clock is usually off by months, and so upstreams
      # in unbound using TLS will fail due to the cert dates being in the future.
      # So we either need to use another server here, or change the upstreams in unbound.conf.
      # "resolv.conf".text = lib.mkForce "nameserver 127.0.0.1";
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
      kopia
      lsof
      mosh
      neovim-unwrapped
      nmap
      openssl
      psmisc
      rsync
      syncthing
      tmux
      wget
      zsh
    ];
  };
}
