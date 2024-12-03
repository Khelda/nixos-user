{
  description = "Custom user configuration. Thanks for the idea, thesola.";

  inputs = {
    nvim.url = "github:Khelda/nvim-config";
    zshrc.url = "github:Khelda/zshrc.d";
    cli-goodies.url = "git+https://cloud.thesola.io/git/thesola10/cli-goodies";
  };

  outputs = { self, nvim, zshrc, cli-goodies, ... }: {
    nixosModules.default = { pkgs, config, lib, ... }@m:
      import ./default.nix ({ inherit zshrc nvim cli-goodies; } // m);
  };
}
