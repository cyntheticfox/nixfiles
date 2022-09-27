{
  ### Nixpkgs
  #
  nixpkgs-master.to = {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    ref = "master";
  };

  nixpkgs-staging.to = {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    ref = "staging";
  };

  nixpkgs-unstable.to = {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    ref = "nixpkgs-unstable";
  };

  nixos-unstable.to = {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    ref = "nixos-unstable";
  };

  # TODO: Make dynamic
  nixos-stable.to = {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    ref = "nixos-20.05";
  };

  # TODO: Make dynamic
  nixpkgs-stable.to = {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    ref = "release-20.05";
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
