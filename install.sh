#!/usr/bin/env bash
set -e

REPO_DIR="$HOME/menudisplay_setup"
REPO_URL="git@github.com:Andrewsleao/menudisplay_setup.git"
CRON_LINE='5 0 * * * cd /home/mila/menudisplay_setup && git fetch origin main && git reset --hard origin/main ; reboot'

echo "Updating system..."
sudo apt update

echo "Installing packages..."
sudo apt install -y git xosd-bin curl wget openssh-client unclutter 

# Chromium best-effort (different distros package it differently)
if sudo apt install -y chromium-browser 2>/dev/null; then
  echo "Installed chromium-browser"
elif sudo apt install -y chromium 2>/dev/null; then
  echo "Installed chromium"
else
  if command -v snap >/dev/null 2>&1; then
    sudo snap install chromium || true
  fi
fi

echo "Configuring git..."
git config --global user.name "Andrews Leao"
git config --global user.email "7255022+Andrewsleao@users.noreply.github.com"

echo "Checking SSH key..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

if [ ! -f ~/.ssh/id_ed25519 ]; then
  echo "No SSH key found. Generating one..."
  ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f ~/.ssh/id_ed25519 -N ""
fi

# Avoid first-time SSH prompt for github.com
ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null || true

# Only pause if repo is not cloned yet (you still need to add the key)
if [ ! -d "$REPO_DIR/.git" ]; then
  echo
  echo "=================================================="
  echo "Add this SSH key to GitHub before continuing:"
  echo
  cat ~/.ssh/id_ed25519.pub
  echo
  echo "GitHub → https://github.com/settings/keys"
  echo "=================================================="
  echo
  read -r -p "Press ENTER after the key has been added to GitHub..." </dev/tty
fi

echo "Starting ssh-agent..."
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519 >/dev/null 2>&1 || true

echo "Testing GitHub connection..."

echo "Cloning repo..."
if [ ! -d "$REPO_DIR/.git" ]; then
  git clone "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"
git config pull.ff only

echo "Linking autostart files..."
mkdir -p ~/.config/autostart
for f in "$REPO_DIR"/autostart/*.desktop; do
  ln -sf "$f" ~/.config/autostart/
done

echo "Disabling XFCE display popup on HDMI changes..."
if command -v xfconf-query >/dev/null 2>&1; then
  xfconf-query -c displays -p /Notify -n -t int -s 0 2>/dev/null || \
  xfconf-query -c displays -p /Notify -s 0 2>/dev/null || true
fi

if [ -n "${DISPLAY:-}" ] && command -v xfce4-display-settings >/dev/null 2>&1; then
  xfce4-display-settings --minimal >/dev/null 2>&1 &
fi

echo "Setting up nightly update and reboot (root crontab)..."
sudo bash -c "crontab -l 2>/dev/null | grep -Fv '$CRON_LINE' | crontab -"
sudo bash -c "(crontab -l 2>/dev/null; echo '$CRON_LINE') | crontab -"

echo "Setup complete!"
echo "Reboot to start kiosk mode."