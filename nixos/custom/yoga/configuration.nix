{ inputs, lib, config, pkgs, ... }: {

  imports = [ ./hardware-configuration.nix ];

  services.xserver.windowManager.xmonad.config = ./xmonad.hs;

  fonts = {
    packages = with pkgs;
      [
        (iosevka.override {
          set = "custom";
          privateBuildPlan = ''
            [buildPlans.Iosevkacustom]
            family = "Iosevka Custom"
            spacing = "extended"
            serifs = "sans"
            noCvSs = true
            exportGlyphNames = false

            [buildPlans.Iosevkacustom.ligations]
            inherits = "haskell"
          '';
        })
      ];
  };

  services.picom = {
    enable = true;
    settings = {
      corner-radius = 12;
      rounded-corners-exclude = [ "name = 'xmobar'" ];
    };
    backend = "glx";
  };

  networking.hostName = "yoga";

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot =
    true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  services.xserver.displayManager.setupCommands = ''
    LEFT='DP-0'
    RIGHT='DP-4'
    RIGHTRIGHT='HDMI-0'
    ${pkgs.xorg.xrandr}/bin/xrandr \
      --output $LEFT --mode 2560x1440 --rate 155 \
      --output $RIGHT --primary --mode 2560x1440 --pos 2560x0 --right-of $LEFT --rate 155 \
      --output $RIGHTRIGHT --scale 1.25x1.25 --mode 1920x1080 --pos 4000x0 --right-of $RIGHT
    ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
  '';

  hardware.graphics.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.systemPackages = with pkgs;
    [
      (st.overrideAttrs (oldAttrs: rec {
        src = fetchFromGitHub {
          owner = "LukeSmithxyz";
          repo = "st";
          rev = "36d225d71d448bfe307075580f0d8ef81eeb5a87";
          sha256 = "u8E8/aqbL3T4Sz0olazg7VYxq30haRdSB1SRy7MiZiA=";
        };

        buildInputs = oldAttrs.buildInputs ++ [ harfbuzz xorg.libXcursor ];

        configFile = writeText "config.h" (builtins.readFile ./config.h);

        patches = [ ./st-themed_cursor.diff ];

        postPatch = ''
          ${oldAttrs.postPatch}
           cp ${configFile} config.h'';
      }))

    ];
}
