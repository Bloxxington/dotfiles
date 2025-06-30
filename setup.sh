#!/bin/bash
set -e
install_pkg(){if pacman -Qi "$1" >/dev/null 2>&1;then echo "✅ Checkbox Installed ($1 - already installed)";return;fi;sudo pacman -S --noconfirm --needed "$1" >/dev/null 2>&1&&{echo "✅ Checkbox Installed ($1)";return;};yay -S --noconfirm --needed "$1" >/dev/null 2>&1&&{echo "✅ Checkbox Installed ($1)";return;};echo "⚠️  Failed to install ($1)";}
sudo pacman -S --needed base-devel git --noconfirm >/dev/null 2>&1
echo "✅ Checkbox Installed (base-devel and git)"
if ! command -v yay >/dev/null;then git clone https://aur.archlinux.org/yay.git >/dev/null 2>&1;cd yay;makepkg -si --noconfirm >/dev/null 2>&1;cd ..;rm -rf yay;echo "✅ Checkbox Installed (yay AUR helper)";else echo "✅ Checkbox Installed (yay AUR helper - already installed)";fi
install_pkg "i3-wm"
install_pkg "polybar"
install_pkg "thunar"
install_pkg "rofi"
install_pkg "google-chrome"
install_pkg "ttf-jetbrains-mono"
if ! fc-list | grep -qi "Symbols Nerd Font Mono";then mkdir -p ~/.local/share/fonts;cd ~/.local/share/fonts;curl -s -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/SymbolsOnly.zip;unzip -o SymbolsOnly.zip >/dev/null 2>&1;rm -f SymbolsOnly.zip;fc-cache -fv >/dev/null 2>&1;echo "✅ Checkbox Installed (Symbols Nerd Font Mono)";else echo "✅ Checkbox Installed (Symbols Nerd Font Mono - already installed)";fi
mkdir -p ~/dotfiles/i3 ~/dotfiles/polybar
cp -r ~/.config/i3/* ~/dotfiles/i3/ 2>/dev/null||true
cp -r ~/.config/polybar/* ~/dotfiles/polybar/ 2>/dev/null||true
echo "✅ Checkbox Installed (Dotfiles Backup)"
CONFIG=~/.config/i3/config
if ! grep -q 'for_window \[class=".*"\] border pixel 0' "$CONFIG" 2>/dev/null;then echo 'for_window [class=".*"] border pixel 0' >> "$CONFIG";fi
echo "✅ Checkbox Installed (i3 Borderless Config)"
