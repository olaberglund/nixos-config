{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    ./vim.nix
    ./firefox.nix
    ./hardware-configuration.nix
  ];

  # wallpaper: set "~/.background-image"

  nixpkgs = {
    #   packageOverrides = super: let self = super.pkgs; in {
    #     iosevka-term = self.iosevka.override {
    #       set = "term";
    #       privateBuildPlan = ''
    #         [buildPlans.IosevkaCustom]
    #         family = "Iosevka Custom"
    #         spacing = "term"
    #         serifs = "sans"
    #         noCvSs = true
    #         exportGlyphNames = false

    #         [buildPlans.IosevkaCustom.ligations]
    #         inherits = "haskell"
    #       '';
    #     };
    #   };

    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };




  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  # nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  # nix.nixPath = ["/etc/nix/path"];
  # environment.etc =
  #   lib.mapAttrs'
  #   (name: value: {
  #     name = "nix/path/${name}";
  #     value.source = value.flake;
  #   })
  #   config.nix.registry;

  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = ["nix-command" "flakes" ];
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
  };

  environment.systemPackages = with pkgs; [
    git
    (st.overrideAttrs (oldAttrs: rec {
      src = fetchFromGitHub {
          owner = "LukeSmithxyz";
          repo = "st";
          rev = "36d225d71d448bfe307075580f0d8ef81eeb5a87";
          sha256 =  "u8E8/aqbL3T4Sz0olazg7VYxq30haRdSB1SRy7MiZiA=";
      };

      buildInputs = oldAttrs.buildInputs ++ [ harfbuzz ];

      configFile = writeText "config.h" (builtins.readFile ./config.h);
      postPatch = "${oldAttrs.postPatch}\n cp ${configFile} config.h";
    }))
    dmenu
    zoxide
    bitwarden
    spotify
    gromit-mpx
    flameshot
    ghc
    cabal-install
    haskellPackages.haskell-language-server
    neovim
    tmux
    wget
    nitrogen
    feh
    eza
    xclip
    gcc
    gnumake
    zlib
    fzf
    zlib.dev
    # iosevka-term
  ];

  fonts.packages = with pkgs; [
    iosevka
  ];

  programs = {
      zsh = {
          enable = true;
          autosuggestions.enable = true;
          zsh-autoenv.enable = true;
          syntaxHighlighting.enable = true;
          ohMyZsh = {
              enable = true;
              theme = "robbyrussell";
              plugins = [
                "git"
                "npm"
                "history"
                "node"
                "zoxide"
                "cabal"
              ];
          };
      };
  };

  boot.loader.systemd-boot.configurationLimit = 5;

  nix.gc = {
      automatic = true;
      dates = "daily";
  };

  virtualisation.virtualbox.guest.enable = true;

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Enable xmonad
  services.xserver.windowManager.xmonad = {
	enable = true;
	enableContribAndExtras = true;
	config = builtins.readFile ./xmonad.hs;
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
    autoRepeatInterval = 10;
    autoRepeatDelay = 150;

    # Enable the X11 windowing system.
    enable = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.picom.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ola = {
    isNormalUser = true;
    description = "ola";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
    ];
    # openssh.authorizedKeys.keys = [
    #   # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
    # ];
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.defaultUserShell = pkgs.zsh;

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "ola";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
