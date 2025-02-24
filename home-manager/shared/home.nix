# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, lib, config, pkgs, ... }:

{
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
    (pkgs.sunpaper.overrideAttrs
      # bc is needed for moonphases
      (oldAttrs: { buildInputs = oldAttrs.buildInputs ++ [ pkgs.bc ]; }))
    (callPackage ../../pkgs/rofi/package.nix { })
    unstable.lazygit
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
    redshift
    zathura
    pamixer
    playerctl
    gromit-mpx
    bitwarden
    spotify
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
    gcc

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
    dconf
    gtk4

    texliveSmall

  ];

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
        shd101wyy.markdown-preview-enhanced
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

    # ".config/sunpaper/config" = { source = ./sunpaper; };

    ".background-image" = { source = ./wallpaper.jpg; };

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
  };

  gtk.enable = true;
  home.pointerCursor = {
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
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
      pdf = "zathura";
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
