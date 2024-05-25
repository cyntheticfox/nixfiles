# Personal NixOS Configuration

If you're looking at this anywhere else, know I now develop this at
[my sourcehut].

A complete NixOS configuration, tailored to how I do things, usually using custom
color scheming. I've set up with some secrets via [sops-nix][sops-nix], and I
split out as much user configuration into home-manager configurations and
modules as I can. Also once provided a few packages and an overlay, as inspired
by [FoosterOS/2 Warp][foosteros]. Currently pending me getting back into that.

## Programs

Here are a few tools I use:

### Desktop

- [Chromium Ungoogled][chromium-ungoogled] - A decent backup browser with Google
  pieces removed.
- [FiraCode Font][FiraCode] - A nice coding font with ligatures.
- [Firefox][Firefox] - A more open browser than Chrome.
- [kitty][kitty] - A fast, capable terminal interface.
- [mupdf][mupdf] - A PDF viewer with vim-like keybinds.
- [nerd-fonts][nerdfonts] - Fancy fonts for everyone.
- [nheko][nheko] - A Qt desktop client for Matrix.
- [obs][obs] - An extensable screencasting app.
- [qpwgraph][qpwgraph] - A fast Pipewire linker.
- [remmina][remmina] - A versatile remote session client.
- [rofi -- with wayland support][rofi] - An easy menu system.
- [sway][sway] - A customizable window manager.
- [swaylock-effects][swaylock-effects] - Fancy lock screens for Sway.
- [waybar][waybar] - Configurable status bar for Sway.
- [wlogout][wlogout] - Configurable logout screen.

### Terminal

- [direnv][direnv] - Automatic environment setup on folder entry.
- [fish][fish] - A user-friendly command line.
- [git][git] - Simple Version Control System.
- [gnupg][gnupg] - An encryption/digital-signature suite.
- [mopidy][mopidy] - An extendable music server, written in Python.
- [neovim][neovim] - A rewritten Vim for modern use.
- [qemu][qemu] - A suite of tools for virtualization and architecture emulation.
- [starship][starship] - A fancy prompt without being too much.
- [zoxide][zoxide] - A fast z/autojump system.

### Remote

- [opentofu][opentofu] - An open-source IaaS tool.
- [rclone][rclone] - A versatile cloud sync tool.
- [rustic][rustic] - A fast and versatile backup tool.

## Dev

I've got plans, but rarely time or energy to work on them.

### Future TODO

See <https://todo.sr.ht/~cyntheticfox/nixfiles?search=label%3A%22enhancement%22>.

### Bugs

See <https://todo.sr.ht/~cyntheticfox/nixfiles?search=label%3A%22bug%22>.

## Other

For Windows platforms, please see instead [dotfiles.ps1][dotfiles.ps1]

[chromium-ungoogled]: https://ungoogled-software.github.io/ungoogled-chromium-binaries/
[direnv]: https://direnv.net/
[dotfiles.ps1]: https://github.com/cyntheticfox/dotfiles.ps1
[FiraCode]: https://github.com/tonsky/FiraCode
[Firefox]: https://firefox.com/
[fish]: https://fishshell.com
[foosteros]: https://github.com/lilyinstarlight/foosteros
[git]: https://git-scm.com/
[gnupg]: https://gnupg.org/
[kitty]: https://sw.kovidgoyal.net/kitty/
[mopidy]: https://mopidy.com/
[mupdf]: https://mupdf.com/
[my sourcehut]: https://git.sr.ht/~cyntheticfox/nixfiles
[neovim]: https://neovim.io/
[nerdfonts]: https://www.nerdfonts.com/
[nheko]: https://nheko-reborn.github.io/
[obs]: https://obsproject.com/
[qemu]: https://www.qemu.org
[qpwgraph]: https://github.com/rncbc/qpwgraph
[rclone]: https://rclone.org/
[remmina]: https://remmina.org/
[rofi]: https://github.com/lbonn/rofi
[rustic]: https://rustic.cli.rs/
[sops-nix]: https://github.com/Mic92/sops-nix
[starship]: https://starship.rs/
[sway]: https://swaywm.org/
[swaylock-effects]: https://github.com/mortie/swaylock-effects
[waybar]: https://github.com/Alexays/Waybar
[wlogout]: https://github.com/ArtsyMacaw/wlogout
[zoxide]: https://github.com/ajeetdsouza/zoxide
[opentofu]: https://opentofu.org/
