#!/bin/bash


URL="http://10.1.10.137"

HOST=$(hostname)

case "$HOST" in
  menu)
    URL="${URL}/menu-sandwiches.html"
    ;;
  mila-menu2)
    URL="${URL}/menu-burger.html"
    ;;
  menu3)
    URL="${URL}/menu-salgados.html"
    ;;
  menu4)
    URL="${URL}/menu-breakfast.html"
    ;;
  menu-5)
    URL="${URL}/menu-salgados.html"
    ;;
  *)
    URL="${URL}/menu-burger.html"
    ;;
esac

# Pick browser
if command -v exo-open >/dev/null 2>&1; then
  BROWSER="exo-open --launch WebBrowser"
elif command -v google-chrome-stable >/dev/null 2>&1; then
  BROWSER="google-chrome-stable"
elif command -v google-chrome >/dev/null 2>&1; then
  BROWSER="google-chrome"
elif command -v chromium >/dev/null 2>&1; then
  BROWSER="chromium"
elif command -v chromium-browser >/dev/null 2>&1 && chromium-browser --version >/dev/null 2>&1; then
  BROWSER="chromium-browser"
elif [ -x /snap/bin/chromium ]; then
  BROWSER="/snap/bin/chromium"
else
  echo "No supported browser found." >&2
  exit 1
fi

# Ensure we are using X11 display
export DISPLAY="${DISPLAY:-:0}"
export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"

# Wait for X session to be ready
for i in {1..60}; do
  xdpyinfo >/dev/null 2>&1 && break
  sleep 1
done
xdpyinfo >/dev/null 2>&1 || { echo "X not ready (DISPLAY=$DISPLAY)"; exit 1; }

# Wait for the page to be reachable (prevents blank kiosk on boot)
for i in {1..60}; do
  curl -sf "$URL" >/dev/null 2>&1 && break
  sleep 2
done

# Disable blanking
xset s off || true
xset -dpms || true
xset s noblank || true

# Use a temporary profile so you never hit profile-lock / crash restore weirdness
PROFILE_DIR="/tmp/chromium-kiosk-profile"
mkdir -p "$PROFILE_DIR"

while true; do
  "$BROWSER" \
    --kiosk "$URL" \
    --user-data-dir="$PROFILE_DIR" \
    --noerrdialogs \
    --disable-infobars \
    --disable-session-crashed-bubble \
    --disable-features=TranslateUI \
    --disable-restore-session-state \
    --overscroll-history-navigation=0 \
    --ozone-platform=x11 \
    --disable-gpu \
    --use-gl=swiftshader \
    --enable-logging=stderr \
    --v=1 \
    2>>"$HOME/kiosk-browser.log"

  sleep 5
done
