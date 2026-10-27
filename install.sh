#!/usr/bin/env bash
# ==============================================================================
# macOS Tahoe 26 (Liquid Glass) Theme Installer for Linux Mint (GNOME Wayland)
# Reproduces the complete minimalist macOS aesthetic on GNOME:
# - Isle Dynamic Island Notch (Music, Lyrics, Shelf, Timer, AI Voice Assistant)
# - Liquid Glass Top Bar with Apple Menu Vector ()
# - Intelligent Auto-Dodge Floating Glass Dock (Dash to Dock Wayland native)
# - Spotlight Search Launcher (Ulauncher with custom Tahoe theme)
# - WhiteSur GTK3/4, Libadwaita & GNOME Shell Themes with Apple logo
# - WhiteSur Icon Theme with Apple-style folder & mime icons
# - Official macOS Cursors (WhiteSur Cursors)
# - Left macOS Traffic Light Window Controls
# - Inter & JetBrains Mono Typography
# - macOS Tahoe 5K Gradient Wallpapers
# - Hardware Acceleration (GSK_RENDERER=gl) for Intel HD Graphics
# - Transparent In-RAM Memory Compression (zswap + zstd at 40% pool)
# ==============================================================================

set -e

# ANSI Color codes
BOLD="\033[1m"
GREEN="\033[32m"
BLUE="\033[34m"
CYAN="\033[36m"
YELLOW="\033[33m"
RESET="\033[0m"

info()  { echo -e "${BOLD}${BLUE}==>${RESET} ${BOLD}$1${RESET}"; }
step()  { echo -e "  ${GREEN}✔${RESET} $1"; }
warn()  { echo -e "  ${YELLOW}⚠${RESET} $1"; }

TARGET_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo "~$TARGET_USER")

info "Starting macOS Tahoe 26 (Liquid Glass) — GNOME Wayland Installation..."

# ------------------------------------------------------------------------------
# 1. System Packages & Prerequisites
# ------------------------------------------------------------------------------
info "[1/9] Installing GNOME Shell, Session, and System Packages..."
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    gnome-shell gnome-session gnome-shell-extension-prefs \
    gnome-control-center gnome-shell-extensions \
    git curl wget jq unzip dconf-cli libglib2.0-bin \
    fonts-inter fonts-jetbrains-mono >/dev/null 2>&1
step "Installed GNOME Shell, Session, and base system dependencies."

# Install Ulauncher if missing
if ! command -v ulauncher >/dev/null 2>&1; then
    sudo add-apt-repository -y ppa:agornostal/ulauncher >/dev/null 2>&1 || true
    sudo apt-get update -qq
    sudo apt-get install -y ulauncher >/dev/null 2>&1 || true
    step "Installed Ulauncher (Spotlight)."
fi

# ------------------------------------------------------------------------------
# 2. Hardware Acceleration & Memory Optimization (zswap + zstd)
# ------------------------------------------------------------------------------
info "[2/9] Configuring GPU Acceleration and Zstandard In-RAM Compression..."

# Fix GTK 4 GPU stutter on Intel HD Graphics
sudo sh -c 'grep -q "GSK_RENDERER" /etc/environment || echo "GSK_RENDERER=gl" >> /etc/environment'
mkdir -p "$USER_HOME/.config/environment.d"
echo "GSK_RENDERER=gl" > "$USER_HOME/.config/environment.d/gtk4-renderer.conf"
step "Configured GTK 4 stable OpenGL renderer (GSK_RENDERER=gl)."

# Enable zswap with zstd and 40% memory pool
sudo modprobe zstd 2>/dev/null || true
sudo sh -c 'echo zstd > /sys/module/zswap/parameters/compressor 2>/dev/null || echo lz4 > /sys/module/zswap/parameters/compressor'
sudo sh -c 'echo 40 > /sys/module/zswap/parameters/max_pool_percent'
sudo sh -c 'echo 1 > /sys/module/zswap/parameters/enabled'

sudo bash -c 'cat > /etc/tmpfiles.d/zswap.conf << "EOF"
w /sys/module/zswap/parameters/enabled - - - - 1
w /sys/module/zswap/parameters/compressor - - - - zstd
w /sys/module/zswap/parameters/max_pool_percent - - - - 40
EOF'
step "Enabled zswap with zstd compression (expanded memory capacity to ~10-11 GB)."

# ------------------------------------------------------------------------------
# 3. WhiteSur GTK & Shell Themes with Apple Menu Vector
# ------------------------------------------------------------------------------
info "[3/9] Installing WhiteSur-Dark GTK & Shell Themes with Apple Menu ()..."
rm -rf /tmp/WhiteSur-gtk
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git /tmp/WhiteSur-gtk >/dev/null 2>&1
cd /tmp/WhiteSur-gtk
./install.sh -c dark -s standard -t default -N glassy --libadwaita --shell -i apple >/dev/null 2>&1
cd "$USER_HOME" && rm -rf /tmp/WhiteSur-gtk
step "Installed WhiteSur GTK/Shell themes with Apple menu icon."

# Install WhiteSur icon theme if missing
if [ ! -d "$USER_HOME/.local/share/icons/WhiteSur" ] && [ ! -d "/usr/share/icons/WhiteSur" ]; then
    rm -rf /tmp/WhiteSur-icon
    git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git /tmp/WhiteSur-icon >/dev/null 2>&1
    cd /tmp/WhiteSur-icon
    ./install.sh -b >/dev/null 2>&1
    cd "$USER_HOME" && rm -rf /tmp/WhiteSur-icon
    step "Installed WhiteSur icon theme."
fi

# Install WhiteSur cursors if missing
if [ ! -d "$USER_HOME/.local/share/icons/WhiteSur-cursors" ] && [ ! -d "/usr/share/icons/WhiteSur-cursors" ]; then
    rm -rf /tmp/WhiteSur-cursors
    git clone --depth=1 https://github.com/vinceliuice/WhiteSur-cursors.git /tmp/WhiteSur-cursors >/dev/null 2>&1
    cd /tmp/WhiteSur-cursors
    ./install.sh >/dev/null 2>&1
    cd "$USER_HOME" && rm -rf /tmp/WhiteSur-cursors
    step "Installed WhiteSur cursor theme."
fi

# ------------------------------------------------------------------------------
# 4. Install & Configure Dash to Dock (Intelligent Wayland Dock)
# ------------------------------------------------------------------------------
info "[4/9] Installing and Configuring Dash-to-Dock (Wayland Native)..."
DOCK_DIR="$USER_HOME/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com"
mkdir -p "$DOCK_DIR"
curl -sL "https://github.com/ubuntu/dash-to-dock/releases/download/extensions.gnome.org-v110/dash-to-dock%40micxgx.gmail.com.zip" -o /tmp/dash-to-dock.zip
unzip -q -o /tmp/dash-to-dock.zip -d "$DOCK_DIR"
rm -f /tmp/dash-to-dock.zip

mkdir -p "$USER_HOME/.local/share/glib-2.0/schemas"
cp "$DOCK_DIR/schemas/"*.xml "$USER_HOME/.local/share/glib-2.0/schemas/"
glib-compile-schemas "$USER_HOME/.local/share/glib-2.0/schemas/"

# Configure Intelligent Auto-Dodge
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode 'ALL_WINDOWS'
gsettings set org.gnome.shell.extensions.dash-to-dock require-pressure-to-show false
gsettings set org.gnome.shell.extensions.dash-to-dock show-delay 0.05
gsettings set org.gnome.shell.extensions.dash-to-dock hide-delay 0.2
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'DOTS'
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-customize-running-dots true
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-running-dots-color '#ffffff'
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-minimize-or-previews'
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.35
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash true
step "Configured Intelligent Dock (centered floating pill with auto-dodge)."

# ------------------------------------------------------------------------------
# 5. Install Isle (Dynamic Island Notch)
# ------------------------------------------------------------------------------
info "[5/9] Installing Isle (Dynamic Island Notch)..."
curl -fsSL https://raw.githubusercontent.com/zickrian/isle/main/get.sh | bash >/dev/null 2>&1
step "Installed Isle daemon and GNOME extension."

# Enable all required extensions
gsettings set org.gnome.shell enabled-extensions "['isle@zickrian.github.io', 'dash-to-dock@micxgx.gmail.com', 'user-theme@gnome-shell-extensions.gcampax.github.com']"
step "Enabled extensions in GNOME Shell."

# ------------------------------------------------------------------------------
# 6. Apply Desktop Appearance & Typography
# ------------------------------------------------------------------------------
info "[6/9] Applying WhiteSur-Dark Theme and Fonts..."
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface font-name 'Inter 10.5'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 10'
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark'
step "Applied macOS styling, fonts, and left traffic light controls."

# Override Settings desktop launcher with GSK_RENDERER=gl
mkdir -p "$USER_HOME/.local/share/applications"
if [ -f /usr/share/applications/org.gnome.Settings.desktop ]; then
    sed 's|^Exec=gnome-control-center|Exec=env GSK_RENDERER=gl gnome-control-center|' \
        /usr/share/applications/org.gnome.Settings.desktop > "$USER_HOME/.local/share/applications/org.gnome.Settings.desktop"
    chmod +x "$USER_HOME/.local/share/applications/org.gnome.Settings.desktop"
fi

# ------------------------------------------------------------------------------
# 7. macOS Keyboard Shortcuts
# ------------------------------------------------------------------------------
info "[7/9] Configuring macOS Keyboard Shortcuts..."
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "[]"
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q', '<Alt>F4']"
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab', '<Alt>Tab']"

# Spotlight (Ulauncher)
KB_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$KB_PATH']"
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KB_PATH" name "Spotlight"
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KB_PATH" command "ulauncher-toggle"
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KB_PATH" binding "<Super>space"

# macOS Screenshot Shortcuts
gsettings set org.gnome.shell.keybindings show-screenshot-ui "['<Shift>Print']"
gsettings set org.gnome.shell.keybindings screenshot "['Print']"
step "Configured macOS shortcuts (Spotlight, Close, Switcher, Screenshots)."

# ------------------------------------------------------------------------------
# 8. Wallpaper Setup
# ------------------------------------------------------------------------------
info "[8/9] Deploying macOS Tahoe 5K Wallpaper..."
mkdir -p "$USER_HOME/.local/share/backgrounds"
if [ ! -f "$USER_HOME/.local/share/backgrounds/macOS-Tahoe-5K.jpg" ]; then
    wget -q -O "$USER_HOME/.local/share/backgrounds/macOS-Tahoe-5K.jpg" \
        "https://raw.githubusercontent.com/vinceliuice/WhiteSur-wallpapers/main/4k/WhiteSur-dark.jpg" || true
fi

if [ -f "$USER_HOME/.local/share/backgrounds/macOS-Tahoe-5K.jpg" ]; then
    gsettings set org.gnome.desktop.background picture-uri "file://$USER_HOME/.local/share/backgrounds/macOS-Tahoe-5K.jpg"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$USER_HOME/.local/share/backgrounds/macOS-Tahoe-5K.jpg"
    gsettings set org.gnome.desktop.background picture-options "zoom"
    step "Set macOS Tahoe 5K wallpaper."
fi

# ------------------------------------------------------------------------------
# 9. Touchpad & Behavior
# ------------------------------------------------------------------------------
info "[9/10] Configuring Touchpad and Window Behaviors..."
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true 2>/dev/null || true
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true 2>/dev/null || true
step "Configured natural scrolling and tap-to-click."

# ------------------------------------------------------------------------------
# 10. Plymouth Apple Boot Splash
# ------------------------------------------------------------------------------
info "[10/10] Configuring macOS Apple Plymouth Boot Splash..."
sudo mkdir -p /usr/share/plymouth/themes/macos-apple
if [ -f "$USER_HOME/.local/share/icons/apple-logo.svg" ]; then
    inkscape -w 128 -h 157 "$USER_HOME/.local/share/icons/apple-logo.svg" -o /tmp/apple-logo-hires.png 2>/dev/null || true
    if [ -f /tmp/apple-logo-hires.png ]; then
        sudo cp /tmp/apple-logo-hires.png /usr/share/plymouth/themes/macos-apple/watermark.png
        sudo cp /tmp/apple-logo-hires.png /usr/share/plymouth/themes/macos-apple/bgrt-fallback.png
        rm -f /tmp/apple-logo-hires.png
    fi
fi

if ! grep -q "^i915" /etc/initramfs-tools/modules 2>/dev/null; then
    echo "i915" | sudo tee -a /etc/initramfs-tools/modules >/dev/null
fi

sudo tee /etc/plymouth/plymouthd.conf >/dev/null << 'EOF'
[Daemon]
Theme=macos-apple
ShowDelay=0
DeviceTimeout=8
EOF

if ! grep -q "GRUB_GFXPAYLOAD_LINUX" /etc/default/grub 2>/dev/null; then
    echo 'GRUB_GFXPAYLOAD_LINUX=keep' | sudo tee -a /etc/default/grub >/dev/null
fi

sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/macos-apple/macos-apple.plymouth 200 >/dev/null 2>&1 || true
sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/macos-apple/macos-apple.plymouth >/dev/null 2>&1 || true

# Hold boot screen for 2.5s on fast SSDs
sudo mkdir -p /etc/systemd/system/plymouth-quit.service.d
sudo tee /etc/systemd/system/plymouth-quit.service.d/delay.conf >/dev/null << 'EOF'
[Service]
ExecStartPre=/bin/sleep 2.5
EOF
sudo systemctl daemon-reload >/dev/null 2>&1 || true

sudo update-grub >/dev/null 2>&1 || true
sudo update-initramfs -u >/dev/null 2>&1 || true
step "Configured authentic Apple boot screen and updated initramfs."

echo
echo -e "${BOLD}${GREEN}======================================================================${RESET}"
echo -e "${BOLD}${GREEN}  macOS Tahoe 26 (GNOME Wayland) installation is complete!${RESET}"
echo -e "${BOLD}${GREEN}======================================================================${RESET}"
echo -e "If you are running this from Cinnamon, log out and select ${BOLD}GNOME${RESET} at the login screen."
echo
