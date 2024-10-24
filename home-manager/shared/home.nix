# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, lib, config, pkgs, ... }:

let
  sunpaper = pkgs.sunpaper.overrideAttrs
    # Needed for moonphases
    (oldAttrs: { buildInputs = oldAttrs.buildInputs ++ [ pkgs.bc ]; });
in {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    ./vim.nix
  ];

  home = {
    username = "ola";
    homeDirectory = "/home/ola";
  };

  home.packages = with pkgs; [
    inputs.rinder.packages.x86_64-linux.default
    sunpaper
    (callPackage ../../pkgs/rofi/package.nix { })
    zip
    unzip
    ripgrep
    gdrive3
    find-cursor
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
    poppler_utils
    entr
    ranger
    bitwarden-menu
    xsel
    xdotool
    bitwarden-cli
    btop
    steam
    pyright
    anki
    cachix

    nixfmt-classic
    shfmt
    stylua
    marksman
    markdownlint-cli
    fish
    nodePackages.prettier
    nodePackages.typescript-language-server
    lua-language-server
    markdownlint-cli2
    termonad

    texliveSmall

    # ghcid
    # haskellPackages.stack
    # haskellPackages.ghc
    # haskellPackages.cabal-install
    # haskellPackages.haskell-language-server
    haskellPackages.stylish-haskell
    haskellPackages.cabal-fmt
    haskellPackages.fourmolu
  ];

  systemd.user.services.rinderSession = {
    Install = { WantedBy = [ "default.target" ]; };
    Unit = { Description = "Rinder (track expenses)"; };
    Service = {
      WorkingDirectory = "/home/ola/Documents/rinder-docs";
      ExecStart = "${
          lib.getExe inputs.rinder.packages.x86_64-linux.default
        } 1337 transactions.json shopping-list.json";
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
          ${pkgs.zip}/bin/gzip -c /home/ola/Documents/rinder-docs/transactions.json > "$temp_file"
          ${pkgs.gdrive3}/bin/gdrive files update 1xJaSg5vrV9EXG36z74B5ynSgI6jzT-sJ --mime application/json "$temp_file"
          ${pkgs.coreutils}/bin/rm "$temp_file"
        }

        export -f backup

        ${pkgs.coreutils}/bin/echo /home/ola/Documents/rinder-docs/transactions.json | ${pkgs.entr}/bin/entr -rpsn '${pkgs.coreutils}/bin/sleep 5m; backup'
      ''}";
    };
  };

  systemd.user.services.gromitSession = {
    Install = { WantedBy = [ "graphical-session.target" ]; };

    Unit = {
      Description = "Gromit (draw on screen)";
      After = [ "graphical-session.target" ];
    };
    Service = { ExecStart = "${pkgs.gromit-mpx}/bin/gromit-mpx"; };
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions;
      [
        vscodevim.vim
        haskell.haskell
        justusadam.language-haskell
        ms-python.python
        ms-toolsai.jupyter
        github.copilot
        github.copilot-chat
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "lambda-black";
          publisher = "janw4ld";
          version = "0.2.7";
          sha256 = "sha256-8qILFx84t6FkoyZkYdOdr38yW7PwQyQDrmSJXRPFXdw=";
        }
        {
          name = "haskell-linter";
          publisher = "hoovercj";
          version = "0.0.6";
          sha256 = "sha256-MjgqR547GC0tMnBJDMsiB60hJE9iqhKhzP6GLhcLZzk=";
        }
      ];

    mutableExtensionsDir = false;
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

    ".config/dunst/dunstrc" = { source = ./dunstrc; };

    ".config/bwm/config.ini" = { source = ./bwmrc; };

    ".config/sunpaper/config" = { source = ./sunpaper; };

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
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    plugins = [{ plugin = pkgs.vimPlugins.markdown-preview-nvim; }];
  };

  programs.zoxide.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ls = "eza";
      e = "nvim";
      p = "zathura";
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
