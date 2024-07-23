{ writeShellApplication, rofi, coreutils }:
(writeShellApplication {
  name = "launcher_t1";
  runtimeInputs = [ coreutils rofi ];
  text = ''
    dir="$HOME/.config/rofi/launchers/type-1"
    theme='style-11'

    rofi \
      -show drun \
      -theme "''${dir}"/"''${theme}".rasi
  '';
})
