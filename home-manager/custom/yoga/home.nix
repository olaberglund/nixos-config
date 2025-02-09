# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, lib, config, pkgs, ... }:

{
  # You can import other home-manager modules here
  imports = [ ../../shared/home.nix ];

  home.packages = with pkgs; [ inputs.rinder.packages.x86_64-linux.default ];

  home.file = { ".xmobarrc" = { source = ./xmobarrc; }; };

  systemd.user.services.rinderSession = {
    Install = { WantedBy = [ "default.target" ]; };
    Unit = { Description = "Rinder (track expenses)"; };
    Service = {
      WorkingDirectory = "/home/ola/Documents/rinder-docs";
      ExecStart = "${
          lib.getExe inputs.rinder.packages.x86_64-linux.default
        } 1337 transactions.json shopping-list.json";
    };
  };

  systemd.user.services.rinderTransactionsSession = {
    Install = { WantedBy = [ "default.target" ]; };
    Unit = { Description = "Rinder (GDrive backup)"; };
    Service = {
      ExecStart = "${pkgs.writeShellScript "watch-transactions" ''
        #!${pkgs.bash}/bin/bash
        export SHELL=${pkgs.bash}/bin/bash

        backup() {
          temp_file=$(${pkgs.coreutils}/bin/mktemp)
          ${pkgs.zip}/bin/gzip -c /home/ola/Documents/rinder-docs/transactions.json > "$temp_file"
          ${pkgs.gdrive3}/bin/gdrive files update 1xJaSg5vrV9EXG36z74B5ynSgI6jzT-sJ --mime application/json "$temp_file"
          ${pkgs.coreutils}/bin/rm "$temp_file"
        }

        export -f backup

        ${pkgs.coreutils}/bin/echo /home/ola/Documents/rinder-docs/transactions.json | ${pkgs.entr}/bin/entr -rpsn '${pkgs.coreutils}/bin/sleep 5m; backup'
      ''}";
    };
  };
}
