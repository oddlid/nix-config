{
  pkgs,
  ...
}:
{

  # Lix
  nixpkgs.overlays = [
    (final: prev: {
      inherit (final.lixPackageSets.latest)
        nixpkgs-review
        nix-direnv
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];

  nix = {
    package = pkgs.lixPackageSets.latest.lix;
    #optimize.automatic = true; # suggested, but doesn't exist...
    linux-builder = {
      enable = false;
      ephemeral = true;
      # Not quite sure how this option works in this context, but when trying to build conduwuit for aarch64-linux in the builder,
      # I found out, after hours of googling, that I need to pass "--max-jobs 0" to nix build, to be sure _only_ the VM does the building.
      # Without it, it seems macOS was building in parallel with the VM, using the VM binaries (bash), that would ofc not run on macOS,
      # leading to errors that took I while to figure out.
      # So, what I've learnt, is:
      # --max-jobs 0 - disable local builds and only use remote builders
      # --option builders '' / --builders '' - disable remote builders and only use local
      # --option substitute false - disable remote builders and only use local
      #
      # To shut down the VM, run "ssh builder@linux-builder 'shutdown now'".
      # Seems though, that the VM is started again automatically, but at least it fres some RAM.
      maxJobs = 2;
      config = {
        # nix.settings.experimental-features = "nix-command flakes";
        virtualisation = {
          darwin-builder = {
            diskSize = 40 * 1024;
            memorySize = 8 * 1024;
          };
          cores = 6;
        };
      };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
    settings = {
      experimental-features = "nix-command flakes"; # Necessary for using flakes on this system.
      trusted-users = [
        "@admin"
        "oddee"
      ];
      substituters = [
        "https://cache.lix.systems"
      ];
      trusted-public-keys = [
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      ];
    };
  };
}
