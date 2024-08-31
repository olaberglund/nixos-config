{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  name = "rinder";

  src = fetchFromGitHub {
    owner = "olaberglund";
    repo = "rinder";
    rev = "master";
    hash = "sha256-klwiojm4TScG+SehC4sGLiQy1xCU0L4UmJ7G3Pt0lCk=";
  };

  meta = {
    description = "A collection of rofi launchers";
    homepage = "https://github.com/olaberglund/rinder";
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
}

