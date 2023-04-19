# Personal NixOS Configuration

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

- [direnv](https://github.com/direnv/direnv) - Automatic environment setup on folder entry
- [git](https://github.com/git/git) - Simple Version Control System
- [gnupg](https://gnupg.org/) - An encryption/digital-signature suite
- [mopidy](https://github.com/mopidy/mopdiy) - An extensible music server in Python
- [neovim](https://github.com/neovim/neovim) - A rewritten Vim for modern use
- [qemu](https://www.qemu.org) - A suite of tools for virtualization and architecture emulation
- [starship](https://github.com/starship/starship) - A fancy prompt without being too much
- [zsh](https://www.zsh.org/) - Extensible, semi-POSIX Linux shell
- [zoxide](https://github.com/ajeetdsouza/zoxide) - Faster z/autojump system

## Current Bugs

See <https://github.com/cyntheticfox/nixfiles/labels/bug>.

## Future

See <https://github.com/cyntheticfox/nixfiles/labels/enhancement>.

## Other

For Windows platforms, please see instead [cyntheticfox/dotfiles.ps1](https://github.com/cyntheticfox/dotfiles.ps1)

