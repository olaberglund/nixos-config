{ writeShellApplication, sunwait, coreutils, gnused, procps, feh }:
(writeShellApplication {
  name = "my-sunpaper";
  runtimeInputs = [ sunwait coreutils gnused procps feh ];
  text = builtins.readFile ./sunpaper.sh;
  excludeShellChecks =
    [ "SC2001" "SC1090" "SC2004" "SC2086" "SC2091" "SC2027" "SC2046" ];
  bashOptions = [ ];
})
