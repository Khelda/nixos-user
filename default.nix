{ zshrc ? builtins.getFlake "github:Khelda/zshrc.d"
, nvim ? builtins.getFlake "github:Khelda/nvim-config", cli-goodies ?
  builtins.getFlake "git+https://cloud.thesola.io/git/thesola10/cli-goodies"
, pkgs, config, lib, ... }:

let
  cfg = config.users.user-kheldae;

  flakePkgs = flake: flake.outputs.packages."${config.nixpkgs.system}";
in {
  options = {
    users.user-kheldae = with lib; {
      enable = mkEnableOption "khel's user config";

      # basic informations
      name = mkOption {
        type = types.str;
        description = "Username";
        default = "kheldae";
      };

      # config dependencies
      zshOpts = mkOption {
        type = types.bool;
        description = "Optional zshrc deps";
        default = true;
      };
      nvimOpts = mkOption {
        type = types.bool;
        description = "Nvim config LSP";
        default = false;
      };

      # QoL options
      offline = mkOption {
        type = types.bool;
        description = "Install offline variants";
        default = false;
      };

      # Some extras
      extraPkgs = mkOption {
        type = types.listOf types.package;
        description = "Additional packages to add to the home profile";
        default = [ ];
      };
    };
  };

  # Launching the actual user
  config = lib.mkIf cfg.enable {
    users.users."${cfg.name}" = {
      isNormalUser = true;

      # shell settings
      shell = pkgs.zsh;
      programs.zsh.enable = true;

      # user packages
      packages = with pkgs;
        let
          nvimChosen =
            (flakePkgs nvim)."neovim${if cfg.nvimOpts then "-full" else ""}${
              if cfg.offline then "-offline" else ""
            }";
        in [
          nvimChosen
          (flakePkgs zshrc).prereqs
          (flakePkgs cli-goodies).cli-goodies

          # Compilers and build toolchains
          gcc
          gdb
          gnumake
          valgrind

          # Networking utilities
          netcat-gnu
          nmap
          traceroute
          whois
          wol

          # Quality of life
          tmux
          tree
          lshw
        ] ++ cfg.extraPkgs ++ (if cfg.zshOptionals then
          [ (flakePkgs zshrc).optionalDeps ]
        else
          [ ]);
    };

    # installation scripts
    system.userActivationScripts.addMyZshrc = {
      text = ''
        if [[ $(stat -c %a $HOME/.zshrc) == 440 ]]
        then
          chmod 644 $HOME/.zshrc
        else
          mv $HOME/.zshrc $HOME/.zshrc2 || true
        fi
        rm -f $HOME/.zshrc
        ${if cfg.offline then ''
          echo "ZPLUG_REPOS=${(flakePkgs zshrc).bootstrap}" >> $HOME/.zshrc
        '' else
          ""}
        cat ${(flakePkgs zshrc).zshrc} >> $HOME/.zshrc
        chmod 644 $HOME/.zshrc
        echo "[[ -f ~/.zshrc2 ]] && . ~/.zshrc2" >> $HOME/.zshrc
        chmod 440 $HOME/.zshrc
      '';
      deps = [ ];
    };
  };
}
