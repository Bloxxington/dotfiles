#!/bin/bash
echo "Installing..."
sudo pacman -S --noconfirm i3-wm picom polybar dunst rofi
SRC_DIR="$(pwd)"
mkdir -p ~/.config
cp -r "$SRC_DIR/i3" ~/.config/
cp -r "$SRC_DIR/polybar" ~/.config/
cp -r "$SRC_DIR/dunst" ~/.config/
cp -r "$SRC_DIR/picom" ~/.config/
cp "$SRC_DIR/picom/tf2.conf" ~/.config/picom/ 2>/dev/null
echo "Installed!"
