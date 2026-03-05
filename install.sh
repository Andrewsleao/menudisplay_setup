#!/usr/bin/env bash
set -e

echo "Updating system..."
sudo apt update

echo "Installing packages..."
sudo apt install -y git chromium-browser xosd-bin curl wget

echo "Configuring git..."
git config --global user.name "Andrews Leao"
git config --global user.email "7255022+Andrewsleao@users.noreply.github.com"

echo "Checking SSH key..."

mkdir -p ~/.ssh

if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "No SSH key found. Generating one..."
    ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f ~/.ssh/id_ed25519 -N ""
fi

echo
echo "=================================================="
echo "Add this SSH key to GitHub before continuing:"
echo
cat ~/.ssh/id_ed25519.pub
echo
echo "GitHub → https://github.com/settings/keys"
echo "=================================================="
echo

read -p "Press ENTER after the key has been added to GitHub..."

echo "Starting ssh-agent..."
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519 || true

echo "Testing GitHub connection..."
ssh -T git@github.com || true

echo "Cloning repo..."
if [ ! -d ~/menudisplay_setup ]; then
    git clone git@github.com:Andrewsleao/menudisplay_setup.git ~/menudisplay_setup
    cd ~/menudisplay_setup
    git config pull.ff only
fi

echo "Linking autostart files..."
mkdir -p ~/.config/autostart

for f in ~/menudisplay_setup/autostart/*.desktop; do
    ln -sf "$f" ~/.config/autostart/
done

echo "Disabling XFCE display popup on HDMI changes..."
if command -v xfconf-query >/dev/null 2>&1; then
  # Make sure the property exists and is the right type (int)
  xfconf-query -c displays -p /Notify -n -t int -s 0 2>/dev/null || \
  xfconf-query -c displays -p /Notify -s 0 2>/dev/null || true
fi

# Apply immediately if we're running inside a GUI session
if [ -n "${DISPLAY:-}" ] && command -v xfce4-display-settings >/dev/null 2>&1; then
  xfce4-display-settings --minimal >/dev/null 2>&1 &
fi

echo "Setting up nightly update and reboot..."

sudo bash -c '(crontab -l 2>/dev/null; echo "5 0 * * * cd /home/mila/menudisplay_setup && git fetch origin main && git reset --hard origin/main && reboot") | crontab -'

echo "Setup complete!"
echo "Reboot to start kiosk mode."