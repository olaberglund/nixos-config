# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
  ];


  home = {
    username = "ola";
    homeDirectory = "/home/ola";
  };

  home.packages = with pkgs; [
    zip
    unzip
    ripgrep
    xmobar
    nodejs_21
    npm-check
    conda
    arandr
    pandoc
    slack
    nerdfonts
    discord
    peek
    lazygit
    redshift
    zathura
    pamixer
    playerctl

    haskellPackages.stack
    haskellPackages.ghc
    haskellPackages.cabal-install
    haskellPackages.haskell-language-server
    haskellPackages.stylish-haskell

    purs
    spago-unstable
    purs-tidy-bin.purs-tidy-0_10_0
  ];

  # systemd.user.services.rinderSession = {
  #   Install = { WantedBy = [ "default.target" ]; };
  #   Unit = {
  #     Description = "Start Rinder (track expenses)";
  #   };
  #   Service = {
  #       ExecStart = "(cd /home/ola/Code/rinder && ${pkgs.cabal-install}/bin/cabal run rinder -- 1337)";
  #   };
  # };

  home.file = { 
      ".config/nvim" = {
          source = ./nvim;
          recursive = true;
      };

      ".background-image" = {
          source = ./wallpaper.png;
      };

      ".tmux.conf" = {
          source = ./tmux.conf;
      };

      ".config/zathura/zathurarc" = {
          source = ./zathurarc;
      };

      ".local/bin" = {
          source = ./scripts;
          recursive = true;
      };
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs.home-manager.enable = true;

  programs.git = {
      enable = true;
      userName = "Ola Berglund";
      userEmail = "olakjberglund@gmail.com";
  };

  programs.ssh.enable = true;

  programs.ssh.matchBlocks = {
    "github.com-ola" = {
        hostname = "github.com";
        user = "git";
        identityFile = "/home/ola/.ssh/id_ed25519";
    };

    "github.com-esgzonex" = {
        hostname = "github.com";
        user = "git";
        identityFile = "/home/ola/.ssh/id_ed25519_esgzonex";
    };

    "ovh-server" = {
        hostname = "51.254.34.164";
        user = "nonroot";
        port = 50579; 
        identityFile = "/home/ola/.ssh/id_ed25519_esgzonex";
    };
  };

  programs.neovim = {
      enable = true;
      defaultEditor = true;
  };

  programs.zoxide.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
        ls = "eza";
    };
    initExtra = ''
      KEYTIMEOUT=1;
      chpwd() eza 
      autoload -Uz compinit && compinit
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
    '';

    plugins = [
      { 
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
  };

  programs.starship.enable = true;

  
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
