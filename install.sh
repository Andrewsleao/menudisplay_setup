#!/usr/bin/env bash
set -e

echo "Updating system..."
sudo apt update

echo "Installing packages..."
sudo apt install -y git chromium-browser xosd-bin curl wget

echo "Configuring git..."
git config --global user.name "Andrews Leao"
git config --global user.email "7255022+Andrewsleao@users.noreply.github.com"

echo "Generating SSH key..."
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f ~/.ssh/id_ed25519 -N ""
fi

echo "Starting ssh-agent..."
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519 || true

echo "Your SSH key (add to GitHub):"
cat ~/.ssh/id_ed25519.pub

echo "Cloning repo..."
if [ ! -d ~/menudisplay_setup ]; then
    git clone git@github.com:Andrewsleao/menudisplay_setup.git ~/menudisplay_setup
fi

echo "Linking autostart files..."
mkdir -p ~/.config/autostart

for f in ~/menudisplay_setup/autostart/*.desktop; do
    ln -sf "$f" ~/.config/autostart/
done

echo "Setup complete!"
echo "Reboot to start kiosk mode."