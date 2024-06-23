{ inputs, lib, config, pkgs, ... }: {

  imports = [ ./hardware-configuration.nix ];

  services.xserver.windowManager.xmonad.config = ./xmonad.hs;

  fonts = {
    packages = with pkgs;
      [
        (iosevka.override {
          set = "custom";
          privateBuildPlan = ''
            [buildPlans.iosevka-custom]
            family = "Iosevka Custom"
            spacing = "normal"
            serifs = "sans"
            noCvSs = true
            exportGlyphNames = false

            [buildPlans.iosevka-custom.ligations]
            inherits = "haskell"
          '';
        })
      ];
  };

  networking.hostName = "yoga";

  services.xserver.displayManager.setupCommands = ''
    LEFT='DP-0'
    RIGHT='DP-4'
    ${pkgs.xorg.xrandr}/bin/xrandr --output $LEFT  --mode 2560x1440 --rate 155 --output $RIGHT --primary  --mode 2560x1440 --pos 2560x0 --right-of $LEFT --rate 155
    ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
  '';

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

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

        buildInputs = oldAttrs.buildInputs ++ [ harfbuzz ];

        configFile = writeText "config.h" (builtins.readFile ./config.h);

        postPatch = ''
          ${oldAttrs.postPatch}
           cp ${configFile} config.h'';
      }))

    ];
}
