{ config, pkgs, ... }:

{
    home.username = "ola";
    home.homeDirectory = "/home/ola";

    programs.git = {
        enable = true;
        userName = "Ola Berglund";
        userEmail = "olakjberglund@gmail.com";
    };

    home.stateVersion = "23.11";

    programs.home-manager.enable = true;

    programs.zsh.shellAliases = {
        ls = "eza";
        v  = "vim";
    };

}

