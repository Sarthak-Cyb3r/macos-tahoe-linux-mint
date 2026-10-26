# macOS Tahoe 26 (Liquid Glass) on Linux Mint — GNOME Wayland Edition

[![Linux Mint](https://img.shields.io/badge/Linux_Mint-22.x_Ubuntu_24.04-87CF3E?style=flat&logo=linuxmint&logoColor=white)](https://linuxmint.com/)
[![GNOME Shell](https://img.shields.io/badge/GNOME_Shell-46%2B-4a86cf.svg?logo=gnome)](https://www.gnome.org/)
[![Wayland](https://img.shields.io/badge/Display-Wayland-orange?logo=wayland&logoColor=white)](https://wayland.freedesktop.org/)
[![Isle](https://img.shields.io/badge/Notch-Isle_Dynamic_Island-blue)](https://github.com/zickrian/isle)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Transform **Linux Mint** into an authentic, ultra-smooth replica of **macOS Tahoe 26 ("Liquid Glass")** powered by **GNOME Shell on Wayland** and the **Isle Dynamic Island notch**.

Optimized for fluid 60fps animations, intelligent window auto-dodging, native Wayland trackpad gestures, and engineered low-RAM footprint with transparent in-memory Zstandard compression (`zswap` + `zstd`).

---

## ✨ Features & Highlights

- **Dynamic Island Notch (Isle)**:
  - Spring-animated black notch living at the top of your screen.
  - **Music & Lyrics**: Full MPRIS scrubber with live synchronized karaoke lyrics from LRCLIB.
  - **Calls & Meetings**: Active call indicators and preview windows for Meet, WhatsApp, and Telegram.
  - **Focus & Reminders**: Pomodoro focus timer with break rings and task checklist.
  - **Shelf & Clipboard**: Clipboard history and drag-and-drop file tray.
  - **AI Voice Assistant**: Direct hook for Claude Code, Codex, and Antigravity.
- **Liquid Glass Top Menubar**:
  - Transparent glass bar seamlessly blending into your desktop wallpaper.
  - Authentic vector **Apple Menu (``)** replacing GNOME's generic "Activities" button.
- **Intelligent macOS Dock (Wayland Native)**:
  - Centered floating frosted pill dock with 35% translucent blur.
  - Native macOS running indicator dots beneath open applications.
  - **Intelligent Auto-Dodge**: Windows can maximize across the entire screen; hovering the bottom edge glides the dock smoothly over windows with zero resistance (`require-pressure-to-show: false`).
  - Trash can and Launchpad integrated into the dock pill.
- **Hardware Acceleration & Low-RAM Engineering**:
  - **GTK 4 Hardware GL Pipeline**: Enforces `GSK_RENDERER=gl` system-wide, eliminating shader compilation stutter on Intel HD Graphics and legacy GPUs.
  - **Zstandard In-RAM Compression (`zswap` + `zstd`)**: Allocates a 40% memory pool using Facebook's Zstandard algorithm, virtually expanding 4.8 GB physical RAM to ~10–11 GB usable capacity without freezing or disk thrashing.
  - **Lean Extension Architecture**: Limited to 3 lightweight extensions keeping GNOME Shell at ~280 MB and Isle at ~2.6 MB.
- **Spotlight Search**: Ulauncher with custom macOS Tahoe translucent bento palette (`Super + Space`).
- **Mac Keyboard Shortcuts**: Native macOS keybindings (`Super + Space` for Spotlight, `Super + Q` to close windows, `Super + Tab` switcher, `Super + D` for show desktop).
- **Screenshots**: `Shift + PrtScn` opens the interactive region/window selector; `PrtScn` snaps the full screen directly.

---

## ⚡ Quick Start (Automated Install)

Run the automated installer on Linux Mint:

```bash
git clone -b gnome-wayland https://github.com/Sarthak-Cyb3r/macos-tahoe-linux-mint.git
cd macos-tahoe-linux-mint
chmod +x install.sh
./install.sh
```

After installation completes, log out and select **GNOME on Wayland** (or **GNOME**) at the login screen.

---

## 🛠️ Complete Step-by-Step Guide

If you prefer to configure your system manually or understand each component:

### 1. Install GNOME Shell & Core Packages

Linux Mint Cinnamon users can install the lightweight GNOME Shell runtime without pulling unnecessary default applications:

```bash
sudo apt update
sudo apt install -y --no-install-recommends \
    gnome-shell gnome-session gnome-shell-extension-prefs \
    gnome-control-center gnome-shell-extensions \
    git curl wget jq unzip dconf-cli fonts-inter fonts-jetbrains-mono
```

---

### 2. Hardware Acceleration & RAM Optimization

To ensure smooth 60fps animations and prevent lag on systems with ≤ 8 GB RAM:

#### A. Fix GTK 4 GPU Stutter on Intel Graphics
```bash
# Set GTK 4 to use stable OpenGL rendering system-wide
sudo sh -c 'grep -q "GSK_RENDERER" /etc/environment || echo "GSK_RENDERER=gl" >> /etc/environment'

mkdir -p ~/.config/environment.d
echo "GSK_RENDERER=gl" > ~/.config/environment.d/gtk4-renderer.conf
```

#### B. Enable Zstandard Memory Compression (`zswap`)
```bash
sudo sh -c 'echo zstd > /sys/module/zswap/parameters/compressor 2>/dev/null || echo lz4 > /sys/module/zswap/parameters/compressor'
sudo sh -c 'echo 40 > /sys/module/zswap/parameters/max_pool_percent'
sudo sh -c 'echo 1 > /sys/module/zswap/parameters/enabled'

# Make persistent across reboots
sudo bash -c 'cat > /etc/tmpfiles.d/zswap.conf << "EOF"
w /sys/module/zswap/parameters/enabled - - - - 1
w /sys/module/zswap/parameters/compressor - - - - zstd
w /sys/module/zswap/parameters/max_pool_percent - - - - 40
EOF'
```

---

### 3. WhiteSur GTK & Shell Themes with Apple Menu

Install the WhiteSur themes and patch the GNOME Shell panel icon to the authentic Apple vector:

```bash
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git /tmp/WhiteSur-gtk
cd /tmp/WhiteSur-gtk
./install.sh -c dark -s standard -t default -N glassy --libadwaita --shell -i apple
cd ~ && rm -rf /tmp/WhiteSur-gtk

# Apply GTK and Shell Themes
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface font-name 'Inter 10.5'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 10'
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'

# Enable User Themes Extension & WhiteSur Shell Theme
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark'
```

---

### 4. Install & Configure the Intelligent macOS Dock (Dash to Dock)

On Wayland, Plank does not run natively. Install upstream Dash to Dock:

```bash
mkdir -p ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com
curl -sL https://github.com/ubuntu/dash-to-dock/releases/download/extensions.gnome.org-v110/dash-to-dock%40micxgx.gmail.com.zip -o /tmp/dash-to-dock.zip
unzip -q -o /tmp/dash-to-dock.zip -d ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com
rm /tmp/dash-to-dock.zip

# Compile Schemas
mkdir -p ~/.local/share/glib-2.0/schemas
cp ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/*.xml ~/.local/share/glib-2.0/schemas/
glib-compile-schemas ~/.local/share/glib-2.0/schemas/

# Configure Intelligent Auto-Dodge Dock
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
```

---

### 5. Install Isle (Dynamic Island Notch)

Install Isle for the current user:

```bash
curl -fsSL https://raw.githubusercontent.com/zickrian/isle/main/get.sh | bash

# Ensure Isle is enabled in GNOME Shell
gsettings set org.gnome.shell enabled-extensions "['isle@zickrian.github.io', 'dash-to-dock@micxgx.gmail.com', 'user-theme@gnome-shell-extensions.gcampax.github.com']"
```

---

### 6. macOS Keybindings & Spotlight Search

Configure Ulauncher and native macOS keyboard shortcuts:

```bash
# Rebind input source switch to free Super+Space
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "[]"

# Mac Window Controls
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q', '<Alt>F4']"
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab', '<Alt>Tab']"

# Spotlight Keybinding (Ulauncher)
KB_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$KB_PATH']"
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KB_PATH" name "Spotlight"
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KB_PATH" command "ulauncher-toggle"
gsettings set "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KB_PATH" binding "<Super>space"

# macOS Screenshot Shortcuts
gsettings set org.gnome.shell.keybindings show-screenshot-ui "['<Shift>Print']"
gsettings set org.gnome.shell.keybindings screenshot "['Print']"
```

---

## ⌨️ Mac Keyboard Shortcuts Reference

| Shortcut | macOS Equivalent | Action |
| :--- | :--- | :--- |
| `Super + Space` | `Cmd + Space` | Spotlight Search (Ulauncher) |
| `Super + Q` | `Cmd + Q` | Quit / Close Active Window |
| `Super + Tab` | `Cmd + Tab` | macOS Application Switcher |
| `Super + D` | `Cmd + F3` | Show Desktop / Minimize All |
| `Shift + PrtScn`| `Cmd + Shift + 4`| Interactive Selection Screenshot Tool |
| `PrtScn` | `Cmd + Shift + 3`| Full-Screen Instant Capture |
| `Super + I` | — | Open Isle Voice Assistant / Panel |

---

## 🔄 Reverting / Rollback

To disable GNOME Wayland customizations or return to your Cinnamon desktop:
Simply log out of your session, click your username, click the gear icon, and select **Cinnamon**. All Cinnamon panels, desklets, and applets remain completely untouched.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
Wallpapers and theme resources belong to their respective authors (WhiteSur by [vinceliuice](https://github.com/vinceliuice), Isle by [zickrian](https://github.com/zickrian/isle)).
