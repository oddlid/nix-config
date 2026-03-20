{
  pkgs,
  ...
}:
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # Think I want to just have the bare minimum shell tools here, and solve
  # the rest with home-manager.
  # TODO: Find out what is best to have here vs in `packages` in HM
  environment.systemPackages = with pkgs; [
    # asn
    # csharpier
    # slint-lsp
    # sqlfluff
    alejandra
    ansible-language-server
    ansible-lint
    bash-language-server
    btop
    coreutils-full
    devenv
    dix
    docker-compose-language-service
    dockerfile-language-server
    duf
    dust
    ghostscript
    git
    hcloud
    helm-ls
    imagemagick
    lua-language-server
    markdown-toc
    markdownlint-cli
    markdownlint-cli2
    marksman
    mc
    mosh
    nh
    nil
    nix-output-monitor
    nixd
    nixfmt
    nixpkgs-fmt
    nodejs_24 # Common for a lot of nvim stuff, so might just always have it
    perlnavigator
    prettier
    pyright
    rage # file encryption
    rclone
    ruff
    shellcheck
    shfmt
    statix
    stylua
    taplo
    tree-sitter
    vim
    vscode-json-languageserver
    vscode-langservers-extracted
    vtsls
    yaml-language-server
    yamllint
    zsh
  ];
}
