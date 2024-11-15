{
  description = "Custom user configuration. Thanks for the idea, thesola.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    # Add custom configs
  };

  outputs = { self, nixpkgs, flake-utils, ... }: { };
}
