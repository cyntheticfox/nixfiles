# Personal NixOS Configuration

A complete NixOS configuration, tailored to how I do things, usually using some kind of "Nord"-like color scheming. Set up with some secrets via [sops-nix][sops-nix], and splitting out user configuration into a home-manager configuration. Also once provided a few packages and an overlay, as inspired by [FoosterOS/2 Warp][foosteros]. Currently pending me getting back into that.

## Programs

Here are a few tools I use:

### Desktop

- [Firefox][Firefox]
- [FiraCode Font][FiraCode]
- [kitty][kitty]
- [nerd-fonts][nerdfonts]
- [remmina][remmina]
- [rofi -- with wayland support][rofi]
- [sway][sway]
- [swaylock-effects][swaylock-effects]
- [waybar][waybar]
- [wlogout][wlogout]

### Terminal

- [direnv][direnv] - Automatic environment setup on folder entry
- [git][git] - Simple Version Control System
- [gnupg][gnupg] - An encryption/digital-signature suite
- [mopidy][mopidy] - An extensible music server in Python
- [neovim][neovim] - A rewritten Vim for modern use
- [qemu][qemu] - A suite of tools for virtualization and architecture emulation
- [starship][starship] - A fancy prompt without being too much
- [zsh][zsh] - Extensible, semi-POSIX Linux shell
- [zoxide][zoxide] - Faster z/autojump system

## Current Bugs

See <https://github.com/cyntheticfox/nixfiles/labels/bug>

## Future

See <https://github.com/cyntheticfox/nixfiles/labels/enhancement>

## Other

For Windows platforms, please see instead [dotfiles.ps1][dotfiles.ps1]

[sops-nix]: https://github.com/Mic92/sops-nix
[Firefox]: https://firefox.com/
[FiraCode]: https://github.com/tonsky/FiraCode
[kitty]: https://github.com/kovidgoyal/kitty
[nerdfonts]: https://github.com/ryanoasis/nerd-fonts
[remmina]: https://gitlab.com/Remmina/Remmina
[rofi]: https://github.com/lbonn/rofi
[sway]: https://github.com/swaywm/sway
[swaylock-effects]: https://github.com/mortie/swaylock-effects
[waybar]: https://github.com/Alexays/Waybar
[wlogout]: https://github.com/ArtsyMacaw/wlogout
[direnv]: https://github.com/direnv/direnv
[git]: https://github.com/git/git
[gnupg]: https://gnupg.org/
[mopidy]: https://github.com/mopidy/mopdiy
[neovim]: https://github.com/neovim/neovim
[qemu]: https://www.qemu.org
[starship]: https://github.com/starship/starship
[zsh]: https://www.zsh.org/
[zoxide]: https://github.com/ajeetdsouza/zoxide
[dotfiles.ps1]: https://github.com/cyntheticfox/dotfiles.ps1
[foosteros]: https://github.com/lilyinstarlight/foosteros
