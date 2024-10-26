{ inputs, lib, config, pkgs, ... }: {

  imports = [ ./hardware-configuration.nix ../../../cachix.nix ];

  services.xserver.windowManager.xmonad.config = ./xmonad.hs;

  # Custom takes too long to build (+ OOM problems)
  fonts = { packages = with pkgs; [ iosevka ]; };

  # For backlight to work: enable acpilight, and join video group
  hardware.acpilight.enable = true;
  users.users.ola.extraGroups = [ "networkmanager" "wheel" "docker" "video" ];

  services.blueman.enable = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot =
    true; # powers up the default Bluetooth controller on boot

  networking.hostName = "latitude";

  services.picom = { enable = true; };

  nix.settings.trusted-users = [ "root" "ola" ];

  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --scale 1.25x1.25
    ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
  '';

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
