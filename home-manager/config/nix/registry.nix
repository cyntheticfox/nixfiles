{
  ### Nixpkgs
  #
  nixpkgs-master.to = {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "master";
  };

  nixpkgs-staging.to = {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "staging";
  };

  nixpkgs-unstable.to = {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "nixpkgs-unstable";
  };

  nixos-unstable.to = {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "nixos-unstable";
  };

  # TODO: Make dynamic
  nixos-stable.to = {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "nixos-20.25";
  };

  # TODO: Make dynamic
  nixpkgs-stable.to = {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "release-20.25";
  };

  ### Other people's configs
  #
  foosteros.to = {
    type = "github";
    owner = "lilyinstarlight";
    repo = "foosteros";
  };

  ### Build tools
  #
  naersk.to = {
    type = "github";
    owner = "nix-community";
    repo = "naersk";
  };

  napalm.to = {
    type = "github";
    owner = "nix-community";
    repo = "napalm";
  };

  node2nix.to = {
    type = "github";
    owner = "svanderburg";
    repo = "node2nix";
  };

  pre-commit-nix.to = {
    type = "github";
    owner = "cachix";
    repo = "pre-commit.nix";
  };
}
