# Steps

1. Copy auto-generated hardware config: `cp /etc/nixos/hardware-configuration.nix ~`
2. Generate key: `ssh-keygen`, use default name
3. Open browser and add key to Github account
4. Clone `nixos-config` to home directory
5. Backup: `sudo mv /etc/nixos /etc/nixos.bak`
6. Symlink: `sudo ln -s ~/nixos-config /etc/nixos`
7. Make any changes
8. `sudo nixos-rebuild switch`
