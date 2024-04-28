# Steps

1. Copy config over to /etc/nixos 
2. Enter a new shell with git: `nix-shell -p git`
3. Try to switch: `sudo nixos-rebuild switch`
4. `ssh-keygen`, use default name
5. Clone config
6. Keep potential changes in used config
7. Backup: `sudo mv /etc/nixos /etc/nixos.bak`
9. Deploy: `sudo nixos-rebuild switch`
8. Symlink: `sudo ln -s ~/nixos-config /nixos`
