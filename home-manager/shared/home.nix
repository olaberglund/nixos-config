# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, lib, config, pkgs, ... }: {
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
    (callPackage ../../pkgs/sunpaper { })
    zip
    unzip
    ripgrep
    gdrive3
    xmobar
    nodejs_22
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
    gromit-mpx
    bitwarden
    spotify
    spotify-player
    btop
    nitrogen
    feh
    zoxide
    dunst
    mpv
    libreoffice
    entr
    ranger
    bitwarden-menu
    xsel
    xdotool
    bitwarden-cli
    btop

    nixfmt-classic
    shfmt
    stylua
    marksman
    markdownlint-cli
    fish
    nodePackages.prettier
    nodePackages.typescript-language-server
    lua-language-server

    texliveSmall

    # ghcid
    # haskellPackages.stack
    # haskellPackages.ghc
    # haskellPackages.cabal-install
    # haskellPackages.haskell-language-server
    haskellPackages.stylish-haskell
    haskellPackages.cabal-fmt
    haskellPackages.fourmolu

    purs
    spago-unstable
    purs-tidy-bin.purs-tidy-0_10_0
  ];

  systemd.user.services.rinderSession = {
    Install = { WantedBy = [ "default.target" ]; };
    Unit = { Description = "Rinder (track expenses)"; };
    Service = {
      WorkingDirectory = "/home/ola/Code/rinder";
      ExecStart = "/home/ola/.local/bin/rinder 1337";
    };
  };

  systemd.user.services.rinderTransactionsSession = {
    Install = { WantedBy = [ "default.target" ]; };
    Unit = { Description = "Rinder (GDrive backup)"; };
    Service = {
      ExecStart = "${pkgs.writeShellScript "watch-transactions" ''
        #!${pkgs.bash}/bin/bash
        export SHELL=${pkgs.bash}/bin/bash

        backup() {
          temp_file=$(${pkgs.coreutils}/bin/mktemp)
          ${pkgs.zip}/bin/gzip -c /home/ola/Code/rinder/transactions.json > "$temp_file"
          ${pkgs.gdrive3}/bin/gdrive files update 1xJaSg5vrV9EXG36z74B5ynSgI6jzT-sJ --mime application/json "$temp_file"
          ${pkgs.coreutils}/bin/rm "$temp_file"
        }

        export -f backup

        ${pkgs.coreutils}/bin/echo /home/ola/Code/rinder/transactions.json | ${pkgs.entr}/bin/entr -rpsn '${pkgs.coreutils}/bin/sleep 5m; backup'
      ''}";
    };
  };

  systemd.user.services.sunpaperSession = {
    Install = { WantedBy = [ "graphical-session.target" ]; };

    Unit = {
      Description = "Sunpaper (automatic wallpapers)";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart =
        "${pkgs.callPackage ../../pkgs/sunpaper { }}/bin/my-sunpaper -d";
    };
  };

  home.file = {
    ".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };

    ".local/bin/" = {
      source = ./scripts;
      recursive = true;
    };

    ".background-images/" = {
      source = ../../pkgs/sunpaper/images;
      recursive = true;
    };

    ".config/dunst/dunstrc" = { source = ./dunstrc; };

    ".config/bwm/config.ini" = { source = ./bwmrc; };

    # ".background-image" = { source = ./wallpaper.png; };

    ".tmux.conf" = { source = ./tmux.conf; };

    ".config/zathura/zathurarc" = { source = ./zathurarc; };

  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  programs.direnv.enable = true;

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
      e = "nvim";
      gp = "git push";
      gs = "git status";
      gd = "git diff";
      lg = "lazygit";
      gc = "git commit";
      ga = "git add";
      gsl = "git stash list --date=local";
      tk = "tmux kill-server";
      gt = "cd $_";
    };
    initExtra = ''
      KEYTIMEOUT=1;
      chpwd() eza 
      autoload -Uz compinit && compinit
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
    '';

    plugins = [{
      name = "vi-mode";
      src = pkgs.zsh-vi-mode;
      file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
    }];
  };

  programs.starship.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
