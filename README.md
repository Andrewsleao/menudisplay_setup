Run this to create symlinks
for f in ~/menu-config/autostart/*.desktop; do
    ln -sf "$f" ~/.config/autostart/
done