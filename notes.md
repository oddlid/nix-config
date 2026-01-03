Some tips found in the NixOS chat:

# marks profiles older than the latest 3 (including current one) to be removed

nix-cleans-profiles1d = "sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +3";

# marks old profiles to be removed

nix-cleans-profiles = "sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations old";

nix-removes-profiles1d = "sudo nix-collect-garbage --delete-older-than 1d"; #removes marked profiles older than 1 day
nix-removes-profiles = "sudo nix-collect-garbage --delete-old"; #removes marked old profiles
nix-removes = "sudo nix-collect-garbage"; #removes leftover dependencies after rebuild

# cleans, removes and confirms removal of old profiles

nix-wipes = "nix-cleans-profiles && nix-removes-profiles && nix-rebuilds";

# cleans, removes and confirms removal of profiles older than 1 day OR than the latest 3 (including current one)

nix-wipes1d = "nix-cleans-profiles1d && nix-removes-profiles1d && nix-rebuilds";

# lists nixos profiles

nix-profiles = "sudo nix-env --profile /nix/var/nix/profiles/system --list-generations";

# lists update differences from the previous version

nix-diffs = "nix store diff-closures /run/\*-system";

`nix-store --gc --print-roots` will tell you what roots exist, if that helps
