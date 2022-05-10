# dotfiles

A complete NixOS configuration, tailored to how I do things, usually using some kind of "Nord"-like color scheming. Set up with some secrets via [sops-nix](https://github.com/Mic92/sops-nix), and splitting out user configuration into a home-manager configuration. Also once provided a few packages and an overlay, as inspired by [FoosterOS/2 Warp](https://github.com/lilyinstarlight/foosteros). Currently pending me getting back into that.

## Initial setup

I like to set up my computer with LUKS, so refer to <https://github.com/sgillespie/nixos-yubikey-luks> as a good setup guide.

## Programs

Here are a few tools I use:

### Desktop

- [Firefox](https://firefox.com/)
- [FiraCode Font](https://github.com/tonsky/FiraCode)
- [kitty](https://github.com/kovidgoyal/kitty)
- [nerd-fonts](https://github.com/ryanoasis/nerd-fonts)
- [remmina](https://gitlab.com/Remmina/Remmina)
- [rofi -- with wayland support](https://github.com/lbonn/rofi)
- [sway](https://github.com/swaywm/sway)
- [swaylock-effects](https://github.com/mortie/swaylock-effects)
- [waybar](https://github.com/Alexays/Waybar)
- [wlogout](https://github.com/ArtsyMacaw/wlogout)

### Terminal

- [direnv](https://github.com/direnv/direnv)
- [git](https://github.com/git/git)
- [gnupg](https://gnupg.org/)
- [mpd](https://musicpd.org/)
- [neovim](https://github.com/neovim/neovim)
- [newsboat](https://newsboat.org/)
- [qemu](https://www.qemu.org)
- [starship](https://github.com/starship/starship)
- [todo.txt](https://github.com/todotxt/todo.txt-cli)
- [vimpc](https://github.com/boysetsfrog/vimpc)
- [zsh](https://www.zsh.org/)
- [zoxide](https://github.com/ajeetdsouza/zoxide)

## Current Bugs

- ACPI device issues on boot
- some duplicate kernel module loads
- ModMic doesn't register or something?
- gnome-keyring doesn't work. Looking into pass-secret-service as replacement.
- Something about `PipeWire` not working with JACK?
- desktop portals failing to load (probably my messy GTK config)
- udiskie doesn't like my GTK config/icons
- playerctld crashes mpd frequently

## Future

- SELinux?
- Secure boot
- Use TPM instead of Yubikey for encryption
- Impermanence/emphemeral system
- bcachefs or zfs instead of btrfs
- Use [danth/stylix](https://github.com/danth/stylix)
- Use pass
- Switch to [nheko](https://github.com/nheko-reborn/nheko) from Element
- Declarative VMs?
- TinyTinyRSS over newsboat
- An actual backup system
- Declarative Firefox config
- More work on [terranix-linode-poc](https://github.com/houstdav000/terranix-linode-poc)

## Other

For Windows platforms, please see instead [houstdav000/dotfiles.ps1](https://github.com/houstdav000/dotfiles.ps1)

