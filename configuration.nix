# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# wallpaper: set "~/.background-image"

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./vim.nix
      ./firefox.nix
    ];

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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ola = {
    isNormalUser = true;
    description = "ola";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
    ];
  };

  users.defaultUserShell = pkgs.zsh;

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "ola";

  nixpkgs.config = {
    allowUnfree = true;

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
  };

  
  nix.settings.experimental-features = ["nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
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
    autojump
    bitwarden
    spotify
    gromit-mpx
    flameshot
    ghc
    cabal-install
    xmobar
    haskell-language-server
    neovim
    tmux
    wget
    nitrogen
    feh
    eza
    # iosevka-term
  ];

  fonts.packages = with pkgs; [
    iosevka
  ];

  programs.zsh = {
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
          ];
      };
  };

  boot.loader.systemd-boot.configurationLimit = 5;

  nix.gc = {
      automatic = true;
      dates = "daily";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
