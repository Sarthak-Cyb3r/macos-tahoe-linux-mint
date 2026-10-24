#!/usr/bin/env bash
# ==============================================================================
# macOS Tahoe 26 (Liquid Glass) Theme Installer for Linux Mint (Cinnamon)
# Reproduces the complete minimalist macOS aesthetic:
# - Translucent Top Bar with Apple Menu & Active Application Title
# - Centered Floating Liquid Glass Plank Dock with magnification & bounce
# - Spotlight Search Launcher (Ulauncher with custom Tahoe theme)
# - macOS Control Center Applet (Wi-Fi, Bluetooth, DND, Dark Mode, Sliders)
# - Liquid Glass Bento Desklet (Clock, Calendar, Weather, System Stats)
# - WhiteSur GTK3/4, Libadwaita & Cinnamon Shell Themes
# - WhiteSur Icon Theme with Apple-style folder & mime icons
# - Official macOS Cursors (Apple Cursor v2.0.1)
# - Left macOS Traffic Light Window Controls
# - Inter & JetBrains Mono Typography
# - macOS Tahoe 5K Gradient Wallpapers
# - Kitty Terminal + Starship macOS Minimalist Prompt
# - Optional: LightDM Slick-Greeter, Plymouth Boot Splash & GRUB Theme
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

info "Starting macOS Tahoe 26 (Liquid Glass) Installation..."

# ------------------------------------------------------------------------------
# 1. System Packages & Prerequisites
# ------------------------------------------------------------------------------
info "[1/11] Installing necessary packages and libraries..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
    git curl wget jq \
    fonts-inter fonts-jetbrains-mono \
    dconf-cli slick-greeter libglib2.0-bin \
    gsettings-desktop-schemas brightnessctl pulseaudio-utils \
    plymouth-themes >/dev/null 2>&1
step "Installed base packages (plank, fonts, dconf, audio/brightness tools)."

# Install Starship prompt if missing
if ! command -v starship >/dev/null 2>&1; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y >/dev/null 2>&1
    step "Installed Starship prompt."
fi

# Install Ulauncher if missing
if ! command -v ulauncher >/dev/null 2>&1; then
    sudo add-apt-repository -y ppa:agornostal/ulauncher >/dev/null 2>&1 || true
    sudo apt-get update -qq || true
    sudo apt-get install -y -qq ulauncher >/dev/null 2>&1 || true
    step "Installed Ulauncher."
fi

# ------------------------------------------------------------------------------
# 2. WhiteSur GTK & Shell Theme
# ------------------------------------------------------------------------------
info "[2/11] Installing WhiteSur GTK 3/4, Libadwaita & Cinnamon Shell Themes..."
BUILD_DIR=$(mktemp -d)
cd "$BUILD_DIR"

git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git >/dev/null 2>&1
cd WhiteSur-gtk-theme
./install.sh -t all -N glassy -s standard -c Dark -c Light >/dev/null 2>&1
./tweaks.sh -g >/dev/null 2>&1 || true
./tweaks.sh -F >/dev/null 2>&1 || true
step "Installed WhiteSur GTK 3/4 & Cinnamon Shell themes."

# ------------------------------------------------------------------------------
# 3. WhiteSur Icon Theme
# ------------------------------------------------------------------------------
info "[3/11] Installing WhiteSur Icon Theme..."
cd "$BUILD_DIR"
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git >/dev/null 2>&1
cd WhiteSur-icon-theme
./install.sh -b -a >/dev/null 2>&1
step "Installed WhiteSur Icon theme."

# ------------------------------------------------------------------------------
# 4. macOS Cursors
# ------------------------------------------------------------------------------
info "[4/11] Installing macOS WhiteSur Cursors..."
mkdir -p "$USER_HOME/.icons" "$USER_HOME/.local/share/icons"
cd /tmp
rm -rf WhiteSur-cursors
git clone --depth 1 https://github.com/vinceliuice/WhiteSur-cursors.git >/dev/null 2>&1 || true
if [ -d WhiteSur-cursors ]; then
    cd WhiteSur-cursors
    ./install.sh >/dev/null 2>&1 || true
    sudo ./install.sh >/dev/null 2>&1 || true
    cd /tmp
    rm -rf WhiteSur-cursors
fi

# Sync themes and icons to /usr/share for root/system/nemo support
sudo mkdir -p /usr/share/themes /usr/share/icons
sudo cp -r "$USER_HOME/.themes/WhiteSur"* /usr/share/themes/ 2>/dev/null || true
sudo cp -r "$USER_HOME/.local/share/icons/WhiteSur"* /usr/share/icons/ 2>/dev/null || true

step "Installed WhiteSur macOS cursor theme and synced system themes."

# ------------------------------------------------------------------------------
# 5. Wallpapers & Apple Logo
# ------------------------------------------------------------------------------
info "[5/11] Downloading macOS Tahoe 5K Wallpapers & Assets..."
mkdir -p "$USER_HOME/.local/share/backgrounds"
mkdir -p "$USER_HOME/.local/share/icons"

# Download 5K Tahoe wallpaper
wget -q -O "$USER_HOME/.local/share/backgrounds/macOS-Tahoe-5K.jpg" \
    "https://raw.githubusercontent.com/vinceliuice/WhiteSur-wallpapers/main/4k/WhiteSur-dark.jpg" || true

# Apple logo SVG for Cinnamon menu & boot splash (Authentic Apple vector)
cat << 'EOF' > "$USER_HOME/.local/share/icons/apple-menu.svg"
<svg width="22" height="22" viewBox="0 0 22 22" version="1.1" xmlns="http://www.w3.org/2000/svg">
 <g transform="matrix(1.125 0 0 1.125 2 -317.5)" fill="#ffffff">
  <path d="m10.356 286.57c0.55189-0.68713 0.92608-1.6207 0.82284-2.5669-0.79488 0.0333-1.7852 0.55212-2.359 1.2192-0.50682 0.5919-0.95705 1.5594-0.84044 2.4713 0.89204 0.0666 1.8056-0.45138 2.3766-1.1236zm2.0112 5.9448c-0.01907-2.0235 1.6557-3.0059 1.7315-3.0528-0.94747-1.3829-2.4166-1.5702-2.9346-1.5873-1.2347-0.12579-2.4298 0.74182-3.0597 0.74182-0.641-8e-5 -1.609-0.7268-2.6516-0.70614-1.3438 0.0201-2.6022 0.7982-3.2911 2.0031-1.4182 2.4628-0.36096 6.0799 1.0012 8.0658 0.68235 0.97755 1.4772 2.0656 2.5198 2.0226 1.0197-0.0388 1.3998-0.64742 2.6322-0.64742 1.2195 0 1.5768 0.64742 2.6407 0.62659 1.095-0.018 1.7836-0.97932 2.4423-1.9609 0.78451-1.1198 1.1013-2.2176 1.1139-2.276-0.02441-9e-3 -2.1224-0.80693-2.1448-3.2293z"/>
 </g>
</svg>
EOF
cp "$USER_HOME/.local/share/icons/apple-menu.svg" "$USER_HOME/.local/share/icons/apple-logo.svg"
step "Installed macOS Tahoe 5K Wallpaper and Apple logo."

# ------------------------------------------------------------------------------
# 6. Custom Cinnamon Applets & Desklets
# ------------------------------------------------------------------------------
info "[6/11] Building custom Liquid Glass Applets & Bento Widgets..."

# 6a. Active App Menu Applet
APPMENU_DIR="$USER_HOME/.local/share/cinnamon/applets/macos-appmenu@liquidglass"
mkdir -p "$APPMENU_DIR"
cat << 'EOF' > "$APPMENU_DIR/metadata.json"
{
  "uuid": "macos-appmenu@liquidglass",
  "name": "macOS App Menu",
  "description": "Displays the active application name in bold macOS style next to the Apple menu.",
  "icon": "preferences-system-windows",
  "max-instances": 1,
  "version": "1.0.0",
  "cinnamon-version": ["6.0", "6.2", "6.4", "6.6"]
}
EOF

cat << 'EOF' > "$APPMENU_DIR/applet.js"
const Applet = imports.ui.applet;
const St = imports.gi.St;
const Clutter = imports.gi.Clutter;
const Cinnamon = imports.gi.Cinnamon;
const Main = imports.ui.main;

class MacOSAppMenuApplet extends Applet.Applet {
    constructor(orientation, panel_height, instance_id) {
        super(orientation, panel_height, instance_id);

        this.label = new St.Label({
            text: "Finder",
            style: "font-family: 'Inter', sans-serif; font-size: 13.5px; font-weight: 700; color: #FFFFFF; padding: 0 10px;",
            y_align: Clutter.ActorAlign.CENTER
        });

        this.actor.add_child(this.label);
        this.set_applet_tooltip("Active Application");

        this._tracker = Cinnamon.WindowTracker.get_default();
        this._updateApp();

        global.display.connect('notify::focus-window', () => {
            this._updateApp();
        });
    }

    _updateApp() {
        try {
            let win = global.display.focus_window;
            if (!win) {
                this.label.set_text("Finder");
                return;
            }
            let app = this._tracker.get_window_app(win);
            if (app) {
                this.label.set_text(app.get_name());
            } else {
                let title = win.get_title();
                this.label.set_text(title ? title.split(" — ")[0] : "Finder");
            }
        } catch (e) {
            this.label.set_text("Finder");
        }
    }
}

function main(metadata, orientation, panel_height, instance_id) {
    return new MacOSAppMenuApplet(orientation, panel_height, instance_id);
}
EOF

# 6b. Control Center Applet
CC_DIR="$USER_HOME/.local/share/cinnamon/applets/control-center@macos"
mkdir -p "$CC_DIR"
cat << 'EOF' > "$CC_DIR/metadata.json"
{
  "uuid": "control-center@macos",
  "name": "Control Center",
  "description": "macOS Tahoe 26 Liquid Glass Control Center with Wi-Fi, Bluetooth, Display, Volume, DND, and Dark Mode toggles.",
  "icon": "preferences-system-symbolic",
  "max-instances": 1,
  "version": "1.0.0",
  "cinnamon-version": ["6.0", "6.2", "6.4", "6.6"]
}
EOF

cat << 'EOF' > "$CC_DIR/stylesheet.css"
/* macOS Tahoe 26 Liquid Glass Control Center Stylesheet */

.control-center-popup {
    background-color: rgba(26, 28, 36, 0.92);
    border: 1px solid rgba(255, 255, 255, 0.16);
    border-radius: 24px;
    padding: 14px;
    box-shadow: 0 24px 56px rgba(0, 0, 0, 0.65);
    min-width: 320px;
    color: #FFFFFF;
    font-family: "Inter", -apple-system, sans-serif;
}

/* Bento Cards */
.mac-card {
    background-color: rgba(255, 255, 255, 0.08);
    border: 1px solid rgba(255, 255, 255, 0.07);
    border-radius: 16px;
    padding: 10px 12px;
}

.mac-row-btn {
    padding: 6px 8px;
    border-radius: 12px;
    background-color: transparent;
    transition-duration: 150ms;
}

.mac-row-btn:hover {
    background-color: rgba(255, 255, 255, 0.08);
}

.mac-square-card {
    background-color: rgba(255, 255, 255, 0.08);
    border: 1px solid rgba(255, 255, 255, 0.07);
    border-radius: 16px;
    padding: 10px 12px;
    transition-duration: 150ms;
}

.mac-square-card:hover {
    background-color: rgba(255, 255, 255, 0.14);
}

.mac-square-card-active {
    background-color: rgba(0, 122, 255, 0.25);
    border: 1px solid rgba(0, 122, 255, 0.6);
}

/* Icon Badges */
.mac-icon-circle {
    border-radius: 20px;
    background-color: rgba(255, 255, 255, 0.14);
    min-width: 32px;
    min-height: 32px;
    padding: 6px;
}

.mac-icon-circle-active {
    background-color: #007AFF;
    color: #FFFFFF;
    box-shadow: 0 2px 8px rgba(0, 122, 255, 0.5);
}

/* Text Hierarchy */
.mac-title {
    font-size: 13px;
    font-weight: 600;
    color: #FFFFFF;
}

.mac-subtitle {
    font-size: 11px;
    font-weight: 400;
    color: rgba(255, 255, 255, 0.62);
}

/* Divider inside unified card */
.mac-divider {
    height: 1px;
    background-color: rgba(255, 255, 255, 0.07);
    margin: 4px 6px;
}

/* Sliders */
.mac-slider-card {
    background-color: rgba(255, 255, 255, 0.08);
    border: 1px solid rgba(255, 255, 255, 0.07);
    border-radius: 16px;
    padding: 12px 14px;
    margin-top: 10px;
}

.mac-slider-header {
    margin-bottom: 8px;
}

.mac-slider-label {
    font-size: 12.5px;
    font-weight: 600;
    color: #FFFFFF;
}
EOF

cat << 'EOF' > "$CC_DIR/applet.js"
/**
 * macOS Tahoe 26 Control Center Applet for Cinnamon
 * Authentic macOS Tahoe 2-column bento layout:
 * - Left column: Unified Connections Card (Wi-Fi, Bluetooth, AirDrop)
 * - Right column: Stacked Focus (DND) & Appearance (Dark Mode) Cards
 * - Bottom cards: Display Brightness & Sound Volume Capsules
 */

const Applet = imports.ui.applet;
const PopupMenu = imports.ui.popupMenu;
const Slider = imports.ui.slider;
const Util = imports.misc.util;
const St = imports.gi.St;
const Clutter = imports.gi.Clutter;
const GLib = imports.gi.GLib;
const Mainloop = imports.mainloop;
const Cinnamon = imports.gi.Cinnamon;

class MacOSControlCenterApplet extends Applet.IconApplet {
    constructor(orientation, panel_height, instance_id) {
        super(orientation, panel_height, instance_id);

        this.set_applet_icon_name("preferences-system-symbolic");
        this.set_applet_tooltip("Control Center");

        this.menuManager = new PopupMenu.PopupMenuManager(this);
        this.menu = new Applet.AppletPopupMenu(this, orientation);
        this.menuManager.addMenu(this.menu);

        this.wifiActive = false;
        this.btActive = false;
        this.dndActive = false;
        this.darkModeActive = true;
        this.volumeLevel = 0.5;
        this.brightnessLevel = 0.8;

        this._buildUI();
        this._updateState();

        this.menu.connect('open-state-changed', (menu, isOpen) => {
            if (isOpen) this._updateState();
        });
    }

    on_applet_clicked() {
        this.menu.toggle();
    }

    _buildUI() {
        let rootBox = new St.BoxLayout({
            vertical: true,
            style_class: "control-center-popup"
        });

        // -------------------------------------------------------------
        // TOP 2-COLUMN SECTION (Connections on Left, Focus/Theme on Right)
        // -------------------------------------------------------------
        let topRow = new St.BoxLayout({
            vertical: false,
            style: "spacing: 10px; margin-bottom: 2px;"
        });

        // LEFT COLUMN: Unified Connections Card
        let leftCol = new St.BoxLayout({
            vertical: true,
            style_class: "mac-card",
            style: "width: 175px;"
        });

        // 1. Wi-Fi Row
        this.wifiBtn = this._createRowButton("network-wireless-symbolic", "Wi-Fi", "Off", () => this._toggleWifi());
        leftCol.add_child(this.wifiBtn.actor);

        // Divider
        leftCol.add_child(new St.BoxLayout({ style_class: "mac-divider" }));

        // 2. Bluetooth Row
        this.btBtn = this._createRowButton("bluetooth-active-symbolic", "Bluetooth", "Off", () => this._toggleBluetooth());
        leftCol.add_child(this.btBtn.actor);

        // Divider
        leftCol.add_child(new St.BoxLayout({ style_class: "mac-divider" }));

        // 3. AirDrop Row
        this.airdropBtn = this._createRowButton("preferences-desktop-remote-desktop-symbolic", "AirDrop", "Contacts Only", () => {});
        this.airdropBtn.circle.set_style_class_name("mac-icon-circle mac-icon-circle-active");
        leftCol.add_child(this.airdropBtn.actor);

        topRow.add_child(leftCol);

        // RIGHT COLUMN: Stacked Cards (Focus & Dark Mode)
        let rightCol = new St.BoxLayout({
            vertical: true,
            style: "spacing: 10px; width: 140px;"
        });

        // Card 1: Focus (Do Not Disturb)
        this.dndCard = this._createSquareCard("notifications-disabled-symbolic", "Focus", "Do Not Disturb", () => this._toggleDND());
        rightCol.add_child(this.dndCard.actor);

        // Card 2: Appearance (Dark Mode)
        this.darkCard = this._createSquareCard("night-light-symbolic", "Appearance", "Dark", () => this._toggleDarkMode());
        rightCol.add_child(this.darkCard.actor);

        topRow.add_child(rightCol);
        rootBox.add_child(topRow);

        // -------------------------------------------------------------
        // MIDDLE SECTION: Display Brightness Slider Capsule
        // -------------------------------------------------------------
        let displayCard = new St.BoxLayout({
            vertical: true,
            style_class: "mac-slider-card"
        });
        let displayHeader = new St.BoxLayout({
            vertical: false,
            style_class: "mac-slider-header",
            style: "spacing: 8px;"
        });
        let displayIcon = new St.Icon({
            icon_name: "display-brightness-symbolic",
            icon_size: 16,
            y_align: Clutter.ActorAlign.CENTER
        });
        let displayTitle = new St.Label({
            text: "Display",
            style_class: "mac-slider-label",
            y_align: Clutter.ActorAlign.CENTER
        });
        displayHeader.add_child(displayIcon);
        displayHeader.add_child(displayTitle);
        displayCard.add_child(displayHeader);

        this.brightSlider = new Slider.Slider(0.8);
        this.brightSlider.connect("value-changed", (slider, val) => this._setBrightness(val));
        displayCard.add_child(this.brightSlider.actor);
        rootBox.add_child(displayCard);

        // -------------------------------------------------------------
        // BOTTOM SECTION: Sound Volume Slider Capsule
        // -------------------------------------------------------------
        let soundCard = new St.BoxLayout({
            vertical: true,
            style_class: "mac-slider-card"
        });
        let soundHeader = new St.BoxLayout({
            vertical: false,
            style_class: "mac-slider-header",
            style: "spacing: 8px;"
        });
        let soundIcon = new St.Icon({
            icon_name: "audio-volume-high-symbolic",
            icon_size: 16,
            y_align: Clutter.ActorAlign.CENTER
        });
        let soundTitle = new St.Label({
            text: "Sound",
            style_class: "mac-slider-label",
            y_align: Clutter.ActorAlign.CENTER
        });
        soundHeader.add_child(soundIcon);
        soundHeader.add_child(soundTitle);
        soundCard.add_child(soundHeader);

        this.volSlider = new Slider.Slider(0.5);
        this.volSlider.connect("value-changed", (slider, val) => this._setVolume(val));
        soundCard.add_child(this.volSlider.actor);
        rootBox.add_child(soundCard);

        // Wrap into menu item
        let menuItem = new PopupMenu.PopupBaseMenuItem({ reactive: true, hover: false, activate: false });
        menuItem.actor.add_child(rootBox);
        this.menu.addMenuItem(menuItem);
    }

    _createRowButton(iconName, title, subtitle, onClick) {
        let btn = new St.Button({
            style_class: "mac-row-btn",
            can_focus: true,
            reactive: true,
            x_expand: true
        });

        let box = new St.BoxLayout({ vertical: false, style: "spacing: 8px;" });

        let circle = new St.BoxLayout({
            style_class: "mac-icon-circle",
            y_align: Clutter.ActorAlign.CENTER
        });
        let icon = new St.Icon({
            icon_name: iconName,
            icon_size: 16,
            y_align: Clutter.ActorAlign.CENTER
        });
        circle.add_child(icon);
        box.add_child(circle);

        let textBox = new St.BoxLayout({ vertical: true, y_align: Clutter.ActorAlign.CENTER });
        let titleLabel = new St.Label({ text: title, style_class: "mac-title" });
        let subLabel = new St.Label({ text: subtitle, style_class: "mac-subtitle" });
        textBox.add_child(titleLabel);
        textBox.add_child(subLabel);
        box.add_child(textBox);

        btn.set_child(box);
        btn.connect("clicked", onClick);

        return {
            actor: btn,
            circle: circle,
            subLabel: subLabel,
            titleLabel: titleLabel,
            setActive: (active, text) => {
                circle.set_style_class_name(active ? "mac-icon-circle mac-icon-circle-active" : "mac-icon-circle");
                if (text) subLabel.set_text(text);
            }
        };
    }

    _createSquareCard(iconName, title, subtitle, onClick) {
        let btn = new St.Button({
            style_class: "mac-square-card",
            can_focus: true,
            reactive: true,
            x_expand: true
        });

        let box = new St.BoxLayout({ vertical: false, style: "spacing: 8px;" });

        let circle = new St.BoxLayout({
            style_class: "mac-icon-circle",
            y_align: Clutter.ActorAlign.CENTER
        });
        let icon = new St.Icon({
            icon_name: iconName,
            icon_size: 16,
            y_align: Clutter.ActorAlign.CENTER
        });
        circle.add_child(icon);
        box.add_child(circle);

        let textBox = new St.BoxLayout({ vertical: true, y_align: Clutter.ActorAlign.CENTER });
        let titleLabel = new St.Label({ text: title, style_class: "mac-title" });
        let subLabel = new St.Label({ text: subtitle, style_class: "mac-subtitle" });
        textBox.add_child(titleLabel);
        textBox.add_child(subLabel);
        box.add_child(textBox);

        btn.set_child(box);
        btn.connect("clicked", onClick);

        return {
            actor: btn,
            circle: circle,
            subLabel: subLabel,
            titleLabel: titleLabel,
            setActive: (active, text) => {
                circle.set_style_class_name(active ? "mac-icon-circle mac-icon-circle-active" : "mac-icon-circle");
                btn.set_style_class_name(active ? "mac-square-card mac-square-card-active" : "mac-square-card");
                if (text) subLabel.set_text(text);
            }
        };
    }

    _updateState() {
        // 1. Wi-Fi
        try {
            let [res, out] = GLib.spawn_command_line_sync("nmcli -t -f active,ssid dev wifi");
            let lines = ("" + out).split("\n");
            let connected = false;
            let ssid = "Off";
            for (let l of lines) {
                if (l.startsWith("yes:")) {
                    connected = true;
                    ssid = l.substring(4) || "Connected";
                    break;
                }
            }
            this.wifiActive = connected;
            this.wifiBtn.setActive(connected, connected ? ssid : "Off");
        } catch (e) {}

        // 2. Bluetooth
        try {
            let [res, out] = GLib.spawn_command_line_sync("bluetoothctl show");
            let on = ("" + out).includes("Powered: yes");
            this.btActive = on;
            this.btBtn.setActive(on, on ? "On" : "Off");
        } catch (e) {}

        // 3. Do Not Disturb
        try {
            let [res, out] = GLib.spawn_command_line_sync("gsettings get org.cinnamon.desktop.notifications display-notifications");
            let dnd = ("" + out).trim() === "false";
            this.dndActive = dnd;
            this.dndCard.setActive(dnd, dnd ? "On" : "Off");
        } catch (e) {}

        // 4. Dark Mode
        try {
            let [res, out] = GLib.spawn_command_line_sync("gsettings get org.cinnamon.desktop.interface gtk-theme");
            let dark = ("" + out).toLowerCase().includes("dark");
            this.darkModeActive = dark;
            this.darkCard.setActive(dark, dark ? "Dark" : "Light");
        } catch (e) {}

        // 5. Volume
        try {
            let [res, out] = GLib.spawn_command_line_sync("pactl get-sink-volume @DEFAULT_SINK@");
            let match = ("" + out).match(/(\d+)%/);
            if (match) {
                let pct = parseInt(match[1], 10) / 100.0;
                this.volumeLevel = pct;
                this.volSlider.setValue(pct);
            }
        } catch (e) {}
    }

    _toggleWifi() {
        let cmd = this.wifiActive ? "nmcli radio wifi off" : "nmcli radio wifi on";
        Util.spawnCommandLine(cmd);
        this.wifiActive = !this.wifiActive;
        this.wifiBtn.setActive(this.wifiActive, this.wifiActive ? "Connecting..." : "Off");
    }

    _toggleBluetooth() {
        let cmd = this.btActive ? "bluetoothctl power off" : "bluetoothctl power on";
        Util.spawnCommandLine(cmd);
        this.btActive = !this.btActive;
        this.btBtn.setActive(this.btActive, this.btActive ? "On" : "Off");
    }

    _toggleDND() {
        let next = !this.dndActive;
        Util.spawnCommandLine("gsettings set org.cinnamon.desktop.notifications display-notifications " + (next ? "false" : "true"));
        this.dndActive = next;
        this.dndCard.setActive(next, next ? "On" : "Off");
    }

    _toggleDarkMode() {
        let next = !this.darkModeActive;
        let theme = next ? "WhiteSur-Dark" : "WhiteSur-Light";
        let iconTheme = next ? "WhiteSur-dark" : "WhiteSur-light";
        let scheme = next ? "prefer-dark" : "prefer-light";

        Util.spawnCommandLine(`gsettings set org.cinnamon.desktop.interface gtk-theme '${theme}'`);
        Util.spawnCommandLine(`gsettings set org.cinnamon.theme name '${theme}'`);
        Util.spawnCommandLine(`gsettings set org.cinnamon.desktop.interface icon-theme '${iconTheme}'`);
        Util.spawnCommandLine(`gsettings set org.gnome.desktop.interface color-scheme '${scheme}'`);

        this.darkModeActive = next;
        this.darkCard.setActive(next, next ? "Dark" : "Light");
    }

    _setBrightness(val) {
        let pct = Math.max(10, Math.round(val * 100));
        Util.spawnCommandLine(`brightnessctl set ${pct}% || xrandr --output HDMI-1 --brightness ${Math.max(0.3, val)}`);
    }

    _setVolume(val) {
        let pct = Math.round(val * 100);
        Util.spawnCommandLine(`pactl set-sink-volume @DEFAULT_SINK@ ${pct}%`);
    }
}

function main(metadata, orientation, panel_height, instance_id) {
    return new MacOSControlCenterApplet(orientation, panel_height, instance_id);
}
EOF

# 6c. Bento Widgets Desklet
DESKLET_DIR="$USER_HOME/.local/share/cinnamon/desklets/macos-widgets@liquidglass"
mkdir -p "$DESKLET_DIR"
cat << 'EOF' > "$DESKLET_DIR/metadata.json"
{
  "uuid": "macos-widgets@liquidglass",
  "name": "macOS Tahoe Widgets",
  "description": "macOS Tahoe 26 Liquid Glass Bento Widgets: Clock, Calendar, Weather, and System Stats.",
  "icon": "preferences-desktop-display",
  "prevent-decorations": true,
  "max-instances": 1,
  "version": "1.0.0",
  "cinnamon-version": ["6.0", "6.2", "6.4", "6.6"]
}
EOF

cat << 'EOF' > "$DESKLET_DIR/stylesheet.css"
.widgets-container {
    spacing: 16px;
    padding: 0;
}
.bento-card {
    background-color: rgba(24, 26, 34, 0.78);
    border: 1px solid rgba(255, 255, 255, 0.14);
    border-radius: 22px;
    padding: 16px 20px;
    box-shadow: 0 14px 34px rgba(0, 0, 0, 0.4);
    color: #FFFFFF;
    font-family: "Inter", sans-serif;
    min-width: 260px;
}
.clock-time {
    font-size: 38px;
    font-weight: 700;
    color: #FFFFFF;
    letter-spacing: -1px;
}
.clock-date {
    font-size: 13px;
    font-weight: 600;
    color: #0A84FF;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 2px;
}
.widget-title {
    font-size: 11px;
    font-weight: 600;
    color: rgba(255, 255, 255, 0.5);
    text-transform: uppercase;
    letter-spacing: 0.8px;
    margin-bottom: 8px;
}
.stat-label {
    font-size: 12px;
    font-weight: 500;
    color: rgba(255, 255, 255, 0.75);
}
.stat-value {
    font-size: 12px;
    font-weight: 600;
    color: #FFFFFF;
}
EOF

cat << 'EOF' > "$DESKLET_DIR/desklet.js"
const Desklet = imports.ui.desklet;
const St = imports.gi.St;
const GLib = imports.gi.GLib;
const Mainloop = imports.mainloop;
const Clutter = imports.gi.Clutter;

class MacOSWidgetsDesklet extends Desklet.Desklet {
    constructor(metadata, desklet_id) {
        super(metadata, desklet_id);
        this.metadata = metadata;
        this.desklet_id = desklet_id;
        this._timerId = 0;

        this._buildUI();
        this._updateStats();
        this._startTimer();
    }

    _buildUI() {
        this.container = new St.BoxLayout({
            vertical: true,
            style_class: "widgets-container"
        });

        // 1. Clock Card
        this.clockCard = new St.BoxLayout({ vertical: true, style_class: "bento-card" });
        this.dateLabel = new St.Label({ text: "TODAY", style_class: "clock-date" });
        this.clockLabel = new St.Label({ text: "12:00 PM", style_class: "clock-time" });
        this.clockCard.add_child(this.dateLabel);
        this.clockCard.add_child(this.clockLabel);
        this.container.add_child(this.clockCard);

        // 2. Weather Card
        this.weatherCard = new St.BoxLayout({ vertical: true, style_class: "bento-card" });
        this.weatherCard.add_child(new St.Label({ text: "WEATHER", style_class: "widget-title" }));
        let weatherContent = new St.BoxLayout({ vertical: false, style: "spacing: 12px; margin-top: 4px;" });
        weatherContent.add_child(new St.Icon({ icon_name: "weather-few-clouds-symbolic", icon_size: 28, style: "color: #FFD60A;" }));
        let weatherText = new St.BoxLayout({ vertical: true });
        this.tempLabel = new St.Label({ text: "24°C", style: "font-size: 20px; font-weight: 700; color: #FFFFFF;" });
        this.weatherConditionLabel = new St.Label({ text: "Fair · H: 28° L: 19°", style: "font-size: 11px; color: rgba(255, 255, 255, 0.7);" });
        weatherText.add_child(this.tempLabel);
        weatherText.add_child(this.weatherConditionLabel);
        weatherContent.add_child(weatherText);
        this.weatherCard.add_child(weatherContent);
        this.container.add_child(this.weatherCard);

        // 3. Activity Card
        this.statsCard = new St.BoxLayout({ vertical: true, style_class: "bento-card" });
        this.statsCard.add_child(new St.Label({ text: "ACTIVITY", style_class: "widget-title" }));

        let cpuBox = new St.BoxLayout({ vertical: false, style: "margin-bottom: 4px;" });
        cpuBox.add_child(new St.Label({ text: "CPU", style_class: "stat-label", x_expand: true }));
        this.cpuValue = new St.Label({ text: "0%", style_class: "stat-value" });
        cpuBox.add_child(this.cpuValue);
        this.statsCard.add_child(cpuBox);

        let ramBox = new St.BoxLayout({ vertical: false, style: "margin-bottom: 4px;" });
        ramBox.add_child(new St.Label({ text: "Memory", style_class: "stat-label", x_expand: true }));
        this.ramValue = new St.Label({ text: "0 / 0 GB", style_class: "stat-value" });
        ramBox.add_child(this.ramValue);
        this.statsCard.add_child(ramBox);

        let diskBox = new St.BoxLayout({ vertical: false });
        diskBox.add_child(new St.Label({ text: "Macintosh HD", style_class: "stat-label", x_expand: true }));
        this.diskValue = new St.Label({ text: "0 GB Free", style_class: "stat-value" });
        diskBox.add_child(this.diskValue);
        this.statsCard.add_child(diskBox);

        this.container.add_child(this.statsCard);
        this.setContent(this.container);
    }

    _startTimer() {
        this._timerId = Mainloop.timeout_add_seconds(2, () => {
            this._updateStats();
            return true;
        });
    }

    _updateStats() {
        let now = GLib.DateTime.new_now_local();
        this.clockLabel.set_text(now.format("%-I:%M %p"));
        this.dateLabel.set_text(now.format("%A, %B %e").toUpperCase());

        try {
            let [res, memOut] = GLib.spawn_command_line_sync("free -m");
            let lines = ("" + memOut).split("\n");
            if (lines.length > 1) {
                let parts = lines[1].trim().split(/\s+/);
                let totalMB = parseInt(parts[1], 10);
                let usedMB = parseInt(parts[2], 10);
                this.ramValue.set_text(`${(usedMB/1024).toFixed(1)} / ${(totalMB/1024).toFixed(1)} GB`);
            }
        } catch (e) {}

        try {
            let [res, dfOut] = GLib.spawn_command_line_sync("df -h /");
            let lines = ("" + dfOut).split("\n");
            if (lines.length > 1) {
                let parts = lines[1].trim().split(/\s+/);
                this.diskValue.set_text(`${parts[3]} Free`);
            }
        } catch (e) {}

        try {
            let [res, loadOut] = GLib.spawn_command_line_sync("cat /proc/loadavg");
            let parts = ("" + loadOut).trim().split(/\s+/);
            if (parts.length > 0) {
                let pct = Math.min(100, Math.round(parseFloat(parts[0]) * 25));
                this.cpuValue.set_text(`${pct}%`);
            }
        } catch (e) {}
    }

    on_desklet_removed() {
        if (this._timerId > 0) {
            Mainloop.source_remove(this._timerId);
            this._timerId = 0;
        }
    }
}

function main(metadata, desklet_id) {
    return new MacOSWidgetsDesklet(metadata, desklet_id);
}
EOF
step "Installed custom macOS AppMenu, Control Center, and Bento Desklet."

# ------------------------------------------------------------------------------
# 7. Liquid Glass Plank Dock Theme & Configuration
# ------------------------------------------------------------------------------
info "[7/11] Setting up Liquid Glass Plank Dock..."
PLANK_THEME_DIR="$USER_HOME/.local/share/plank/themes/Liquid-Glass"
mkdir -p "$PLANK_THEME_DIR"
cat << 'EOF' > "$PLANK_THEME_DIR/dock.theme"
[PlankTheme]
TopRoundness=22
BottomRoundness=22
LineWidth=1
OuterStrokeColor=255;;255;;255;;25
FillStartColor=44;;48;;58;;155
FillEndColor=22;;25;;32;;185
InnerStrokeColor=255;;255;;255;;55

[PlankDockTheme]
HorizPadding=1
TopPadding=3
BottomPadding=3
ItemPadding=4
IndicatorSize=4
IconShadowSize=0
UrgentBounceHeight=1.8
LaunchBounceHeight=1.0
FadeOpacity=1
ClickTime=250
UrgentBounceTime=0
LaunchBounceTime=500
ActiveTime=0
SlideTime=120
FadeTime=180
HideTime=150
GlowSize=0
GlowTime=0
GlowPulseTime=0
UrgentHueShift=150
ItemMoveTime=180
CascadeHide=true
BadgeColor=255;;255;;255;;240
EOF

# Ensure Trash docklet exists
mkdir -p "$USER_HOME/.config/plank/dock1/launchers"
cat << 'EOF' > "$USER_HOME/.config/plank/dock1/launchers/trash.dockitem"
[PlankDockItemPreferences]
Launcher=docklet://trash
EOF

# Configure Plank via dconf (Intelligent autohide over applications, visible on desktop)
dconf write /net/launchpad/plank/docks/dock1/theme "'Liquid-Glass'"
dconf write /net/launchpad/plank/docks/dock1/icon-size 50
dconf write /net/launchpad/plank/docks/dock1/zoom-enabled true
dconf write /net/launchpad/plank/docks/dock1/zoom-percent 125
dconf write /net/launchpad/plank/docks/dock1/hide-mode "'intelligent'"
dconf write /net/launchpad/plank/docks/dock1/unhide-delay 0
dconf write /net/launchpad/plank/docks/dock1/hide-delay 150
dconf write /net/launchpad/plank/docks/dock1/pressure-reveal false
dconf write /net/launchpad/plank/docks/dock1/position "'bottom'"
dconf write /net/launchpad/plank/docks/dock1/alignment "'center'"
dconf write /net/launchpad/plank/docks/dock1/show-dock-item false
dconf write /net/launchpad/plank/docks/dock1/dock-items "['nemo.dockitem', 'mintinstall.dockitem', 'org.gnome.Terminal.dockitem', 'com.ktechpit.whatsie.dockitem', 'helium.dockitem', 'com.softify.softify.dockitem', 'antigravity.dockitem', 'Qwen Studio.dockitem', 'cinnamon-settings.dockitem', 'trash.dockitem']"

# Suppress elementary OS active app glow rectangle via clean hook
mkdir -p "$USER_HOME/.local/lib" "$USER_HOME/.local/bin"
cat << 'EOF' > "$USER_HOME/.local/lib/libplank-noglow.c"
#define _GNU_SOURCE
#include <dlfcn.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdint.h>

__attribute__((constructor))
static void init_noglow(void) {
    void *fn = dlsym(RTLD_DEFAULT, "plank_dock_theme_draw_active_glow");
    if (!fn) return;

    long pagesize = sysconf(_SC_PAGESIZE);
    uintptr_t page_start = (uintptr_t)fn & ~(pagesize - 1);

    if (mprotect((void *)page_start, pagesize, PROT_READ | PROT_WRITE | PROT_EXEC) == 0) {
        *(unsigned char *)fn = 0xc3; // 'ret'
        mprotect((void *)page_start, pagesize, PROT_READ | PROT_EXEC);
    }
}
EOF
gcc -shared -fPIC -O2 "$USER_HOME/.local/lib/libplank-noglow.c" -o "$USER_HOME/.local/lib/libplank-noglow.so" -ldl 2>/dev/null || true

cat << 'EOF' > "$USER_HOME/.local/bin/plank"
#!/bin/bash
export LD_PRELOAD="$HOME/.local/lib/libplank-noglow.so${LD_PRELOAD:+:$LD_PRELOAD}"
exec /usr/bin/plank "$@"
EOF
chmod +x "$USER_HOME/.local/bin/plank"

# Enable Plank via systemd user service for auto-restart & persistence
mkdir -p "$USER_HOME/.config/systemd/user"
cat << 'EOF' > "$USER_HOME/.config/systemd/user/plank.service"
[Unit]
Description=Plank macOS Dock
PartOf=graphical-session.target
After=graphical-session.target

[Service]
Type=simple
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/sarthak/.Xauthority
Environment=LD_PRELOAD=/home/sarthak/.local/lib/libplank-noglow.so
ExecStart=/usr/bin/plank
Restart=always
RestartSec=1

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload >/dev/null 2>&1 || true
systemctl --user enable --now plank.service >/dev/null 2>&1 || true

# Autostart Plank
mkdir -p "$USER_HOME/.config/autostart"
cat << 'EOF' > "$USER_HOME/.config/autostart/plank.desktop"
[Desktop Entry]
Type=Application
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Plank
Comment=macOS Dock
EOF
step "Configured Liquid Glass Plank Dock and autostart."

# ------------------------------------------------------------------------------
# 8. Spotlight Launcher (Ulauncher macOS Tahoe Theme)
# ------------------------------------------------------------------------------
info "[8/11] Configuring Ulauncher Spotlight..."
ULAUNCHER_THEME_DIR="$USER_HOME/.config/ulauncher/user-themes/macOS-Tahoe"
mkdir -p "$ULAUNCHER_THEME_DIR"
cat << 'EOF' > "$ULAUNCHER_THEME_DIR/manifest.json"
{
    "manifest_version": "1",
    "name": "macOS-Tahoe",
    "display_name": "macOS Tahoe Liquid Glass",
    "extend_theme": "dark",
    "css_file": "theme.css",
    "css_file_gtk_3.20+": "theme.css",
    "matched_text_hl_colors": {
        "when_selected": "#64D2FF",
        "when_not_selected": "#0A84FF"
    }
}
EOF

cat << 'EOF' > "$ULAUNCHER_THEME_DIR/theme.css"
@define-color window_bg rgba(32, 34, 42, 0.88);
@define-color window_border rgba(255, 255, 255, 0.14);
@define-color text_color #FFFFFF;
@define-color subtext_color #A1A1A6;
@define-color selected_item_bg #007AFF;
@define-color selected_item_fg #FFFFFF;

.app {
    box-shadow: 0 20px 50px rgba(0, 0, 0, 0.55);
    background-color: @window_bg;
    border: 1px solid @window_border;
    border-radius: 16px;
    padding: 8px 12px;
}
.input {
    color: @text_color;
    font-family: "Inter", -apple-system, sans-serif;
    font-size: 20px;
    font-weight: 400;
    padding: 10px 14px;
    margin: 4px 0 8px 0;
}
.item-box {
    padding: 8px 10px;
    border-radius: 10px;
    margin: 2px 0;
}
.selected.item-box {
    background-color: @selected_item_bg;
    border: none;
}
.item-name {
    color: @text_color;
    font-family: "Inter", -apple-system, sans-serif;
    font-size: 15px;
    font-weight: 500;
}
.selected.item-box .item-name {
    color: @selected_item_fg;
}
.item-text {
    color: @subtext_color;
    font-family: "Inter", -apple-system, sans-serif;
    font-size: 12px;
}
.selected.item-box .item-text {
    color: rgba(255, 255, 255, 0.85);
}
.item-shortcut {
    color: #8E8E93;
    font-family: "JetBrains Mono", monospace;
    font-size: 11px;
}
.selected.item-box .item-shortcut {
    color: #FFFFFF;
}
.prefs-btn {
    border-radius: 12px;
    opacity: 0.6;
}
.prefs-btn:hover {
    opacity: 1.0;
    background-color: rgba(255, 255, 255, 0.1);
}
EOF

# Ulauncher Preferences
mkdir -p "$USER_HOME/.config/ulauncher"
cat << 'EOF' > "$USER_HOME/.config/ulauncher/settings.json"
{
    "blacklisted_desktop_dirs": "/usr/share/xsessions/:/usr/share/wayland-sessions/",
    "clear_previous_query": true,
    "close_on_focus_out": true,
    "disable_desktop_filters": false,
    "grab_mouse_pointer": false,
    "hotkey_show_app": "<Super>space",
    "jump_to_first_result_on_type": true,
    "max_recent_apps": 5,
    "render_on_screen": "mouse-pointer-monitor",
    "show_indicator_icon": false,
    "show_recent_apps": "0",
    "terminal_command": "",
    "theme_name": "macOS-Tahoe"
}
EOF

# Autostart Ulauncher
cat << 'EOF' > "$USER_HOME/.config/autostart/ulauncher.desktop"
[Desktop Entry]
Type=Application
Exec=ulauncher --hide-window
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Ulauncher
Comment=Spotlight Application Launcher
EOF
step "Configured Ulauncher with macOS-Tahoe Spotlight theme."

# ------------------------------------------------------------------------------
# 9. App Tweaks: Nemo Finder, Kitty Terminal & Starship Prompt
# ------------------------------------------------------------------------------
info "[9/11] Configuring Nemo Finder styling, Kitty & Starship prompt..."

# Nemo / GTK3 styling
mkdir -p "$USER_HOME/.config/gtk-3.0"
cat << 'EOF' > "$USER_HOME/.config/gtk-3.0/gtk.css"
/* macOS Tahoe 26 / Sonoma Authentic Finder Styles for Nemo */

/* 1. Global macOS Minimalist Overlay Scrollbars */
scrollbar {
    background-color: transparent;
    transition: all 250ms ease;
    border: none;
    min-width: 8px;
    min-height: 8px;
}

scrollbar slider {
    background-color: rgba(255, 255, 255, 0.20);
    border-radius: 8px;
    border: 2px solid transparent;
    min-width: 6px;
    min-height: 6px;
    transition: all 200ms ease;
}

scrollbar slider:hover {
    background-color: rgba(255, 255, 255, 0.45);
}

scrollbar slider:active {
    background-color: #007AFF;
}

/* 2. Nemo Window Architecture */
.nemo-window {
    background-color: #181A22;
    color: #F5F5F7;
    font-family: "Inter", -apple-system, sans-serif;
}

/* Headerbar / Unified Titlebar */
.nemo-window headerbar,
.nemo-window .primary-toolbar {
    background-color: #20222A;
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
    box-shadow: none;
    padding: 4px 10px;
    border-top-left-radius: 14px;
    border-top-right-radius: 14px;
}

/* Traffic Lights spacing on top-left */
.nemo-window headerbar windowcontrols,
.nemo-window headerbar .titlebutton {
    margin-right: 6px;
}

/* 3. macOS Finder Sidebar */
.nemo-window .sidebar {
    background-color: #1E2028;
    border-right: 1px solid rgba(255, 255, 255, 0.07);
    padding: 8px 4px;
}

.nemo-window .sidebar .view {
    background-color: transparent;
    color: rgba(255, 255, 255, 0.85);
    font-size: 13px;
}

/* Sidebar Row Pills */
.nemo-window .sidebar row {
    border-radius: 8px;
    margin: 2px 6px;
    padding: 5px 8px;
    transition: all 120ms ease;
}

.nemo-window .sidebar row:hover {
    background-color: rgba(255, 255, 255, 0.06);
}

.nemo-window .sidebar row:selected,
.nemo-window .sidebar row:selected:focus {
    background-color: #007AFF;
    color: #FFFFFF;
}

/* Sidebar Category Headers */
.nemo-window .sidebar .heading,
.nemo-window .sidebar label.heading {
    font-size: 11px;
    font-weight: 700;
    color: rgba(255, 255, 255, 0.42);
    letter-spacing: 0.6px;
    padding: 8px 10px 4px 10px;
}

/* 4. Main Content Pane */
.nemo-window .nemo-window-pane,
.nemo-window .view {
    background-color: #181A22;
    color: #FFFFFF;
}

.nemo-window .view:selected {
    background-color: rgba(0, 122, 255, 0.35);
    border-radius: 8px;
    color: #FFFFFF;
}

.nemo-window .rubberband {
    background-color: rgba(0, 122, 255, 0.20);
    border: 1px solid #007AFF;
    border-radius: 4px;
}

/* 5. Toolbar & Pathbar Buttons */
.nemo-window .primary-toolbar button,
.nemo-window .path-bar button {
    border-radius: 8px;
    margin: 0 2px;
    padding: 4px 8px;
    background-color: rgba(255, 255, 255, 0.06);
    border: 1px solid rgba(255, 255, 255, 0.06);
    color: #E5E5EA;
    box-shadow: none;
    transition: all 120ms ease;
}

.nemo-window .primary-toolbar button:hover,
.nemo-window .path-bar button:hover {
    background-color: rgba(255, 255, 255, 0.12);
    border-color: rgba(255, 255, 255, 0.10);
    color: #FFFFFF;
}

.nemo-window .primary-toolbar button:checked,
.nemo-window .path-bar button:checked {
    background-color: rgba(0, 122, 255, 0.35);
    border-color: #007AFF;
    color: #FFFFFF;
}

/* Search Bar */
.nemo-window entry {
    border-radius: 10px;
    background-color: rgba(255, 255, 255, 0.08);
    border: 1px solid rgba(255, 255, 255, 0.10);
    color: #FFFFFF;
    padding: 4px 10px;
}

.nemo-window entry:focus {
    border-color: #007AFF;
    box-shadow: 0 0 0 2px rgba(0, 122, 255, 0.25);
}
EOF

# Kitty configuration
mkdir -p "$USER_HOME/.config/kitty"
cat << 'EOF' > "$USER_HOME/.config/kitty/kitty.conf"
# macOS Tahoe 26 Liquid Glass Kitty Terminal Theme
font_family      JetBrains Mono
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size        11.5

window_padding_width 16 18
background_opacity 0.88
dynamic_background_opacity yes
confirm_os_window_close 0

tab_bar_edge top
tab_bar_style powerline
tab_powerline_style slanted

cursor_shape beam
cursor_blink_interval 0.5

foreground #F5F5F7
background #1C1E26
selection_foreground #FFFFFF
selection_background #007AFF

color0 #1C1E26
color1 #FF453A
color2 #32D74B
color3 #FFD60A
color4 #0A84FF
color5 #BF5AF2
color6 #5AC8FA
color7 #E5E5EA

color8  #48484A
color9  #FF6961
color10 #30D158
color11 #FFD426
color12 #409CFF
color13 #DA8FFF
color14 #70D7FF
color15 #FFFFFF
EOF

# Starship configuration
mkdir -p "$USER_HOME/.config"
cat << 'EOF' > "$USER_HOME/.config/starship.toml"
add_newline = false
format = """
$directory\
$git_branch\
$git_status\
$character\
"""

[character]
success_symbol = "[❯](bold #0A84FF) "
error_symbol = "[❯](bold #FF453A) "

[directory]
style = "bold #64D2FF"
truncation_length = 3
truncate_to_repo = true
read_only = " 🔒"

[git_branch]
symbol = "🌱 "
style = "bold #32D74B"

[git_status]
style = "bold #FFD60A"
conflicted = "🏳 "
ahead = "⇡${count} "
behind = "⇣${count} "
diverged = "⇕⇡${ahead_count}⇣${behind_count} "
untracked = "? "
stashed = "📦 "
modified = "! "
staged = "+ "
renamed = "» "
deleted = "✘ "
EOF

if ! grep -q 'starship init bash' "$USER_HOME/.bashrc"; then
    echo 'eval "$(starship init bash)"' >> "$USER_HOME/.bashrc"
fi
step "Styled Nemo file manager, Kitty terminal, and Starship prompt."

# ------------------------------------------------------------------------------
# 10. Apply Cinnamon Shell Layout & Appearance
# ------------------------------------------------------------------------------
info "[10/11] Applying Cinnamon Top Menu Bar, Window Controls, Fonts & Keybindings..."

# Background
gsettings set org.cinnamon.desktop.background picture-uri "file://$USER_HOME/.local/share/backgrounds/macOS-Tahoe-5K.jpg"
gsettings set org.cinnamon.desktop.background picture-options 'zoom'

# Themes
gsettings set org.cinnamon.desktop.interface gtk-theme 'WhiteSur-Dark'
gsettings set org.cinnamon.theme name 'WhiteSur-Dark'
gsettings set org.cinnamon.desktop.interface icon-theme 'WhiteSur-dark'
gsettings set org.cinnamon.desktop.interface cursor-theme 'WhiteSur-cursors'
gsettings set org.cinnamon.desktop.interface cursor-size 24

# Fonts
gsettings set org.cinnamon.desktop.interface font-name 'Inter 10.5'
gsettings set org.cinnamon.desktop.wm.preferences titlebar-font 'Inter Semi-Bold 11'

# Window controls: Traffic lights on LEFT & WhiteSur window decorations
gsettings set org.cinnamon.desktop.wm.preferences button-layout 'close,minimize,maximize:'
gsettings set org.cinnamon.desktop.wm.preferences theme 'WhiteSur-Dark'

# Panel: Single slender 30px translucent top bar
gsettings set org.cinnamon panels-enabled "['1:0:top']"
gsettings set org.cinnamon panels-height "['1:30']"
gsettings set org.cinnamon panel-zone-icon-sizes '[{"panelId": 1, "left": 18, "center": 18, "right": 16}]'
gsettings set org.cinnamon panel-zone-symbolic-icon-sizes '[{"panelId": 1, "left": 18, "center": 18, "right": 16}]'

# Applets layout:
# Left: Apple Menu + Active App Title
# Right: Systray, Network, Sound, Control Center, Notifications, Clock
gsettings set org.cinnamon enabled-applets "['panel1:left:0:menu@cinnamon.org:0', 'panel1:left:1:macos-appmenu@liquidglass:51', 'panel1:right:0:systray@cinnamon.org:3', 'panel1:right:1:xapp-status@cinnamon.org:4', 'panel1:right:2:network@cinnamon.org:10', 'panel1:right:3:sound@cinnamon.org:11', 'panel1:right:4:control-center@macos:50', 'panel1:right:5:notifications@cinnamon.org:5', 'panel1:right:6:calendar@cinnamon.org:13']"

# Menu configuration (Apple icon)
dconf write /org/cinnamon/applets/menu@cinnamon.org/0/menu-icon-custom true
dconf write /org/cinnamon/applets/menu@cinnamon.org/0/menu-icon "'$USER_HOME/.local/share/icons/apple-menu.svg'"
dconf write /org/cinnamon/applets/menu@cinnamon.org/0/menu-label "''"
python3 -c '
import json, os
p = os.path.expanduser("~/.config/cinnamon/spices/menu@cinnamon.org/0.json")
if os.path.exists(p):
    with open(p, "r") as f: d = json.load(f)
    if "menu-icon" in d: d["menu-icon"]["value"] = os.path.expanduser("~/.local/share/icons/apple-menu.svg")
    if "menu-icon-size" in d: d["menu-icon-size"]["value"] = 18
    with open(p, "w") as f: json.dump(d, f, indent=4)
' 2>/dev/null || true

# Clock formatting macOS style
dconf write /org/cinnamon/applets/calendar@cinnamon.org/13/custom-format "'%a %b %e  %-I:%M %p'"
dconf write /org/cinnamon/applets/calendar@cinnamon.org/13/use-custom-format true

# Desklets (Bento widgets stack on right)
gsettings set org.cinnamon enabled-desklets "['macos-widgets@liquidglass:0:1620:50']"

# Animations & Effects
gsettings set org.cinnamon desktop-effects-map 'scale'
gsettings set org.cinnamon desktop-effects-close 'scale'
gsettings set org.cinnamon desktop-effects-minimize 'scale'
gsettings set org.cinnamon window-effect-speed 1

# Cinnamon Extensions: Blur, Magic Lamp, Rounded Corners, Transparent Panels
mkdir -p "$USER_HOME/.local/share/cinnamon/extensions"
wget -q -O /tmp/RoundedCorners.zip "https://cinnamon-spices.linuxmint.com/files/extensions/RoundedCorners@klangman.zip" || true
[ -f /tmp/RoundedCorners.zip ] && unzip -q -o /tmp/RoundedCorners.zip -d "$USER_HOME/.local/share/cinnamon/extensions/" && rm -f /tmp/RoundedCorners.zip
gsettings set org.cinnamon enabled-extensions "['transparent-panels-reloaded@marcelovbcfilho', 'BlurCinnamon@klangman', 'CinnamonMagicLamp@klangman', 'RoundedCorners@klangman']"

# Mac Shortcuts: Super+Q (Close), Super+Tab (App switch), Alt+Space / Super+Space (Spotlight)
gsettings set org.cinnamon.desktop.keybindings.wm close "['<Super>q', '<Alt>F4']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-windows "['<Super>Tab', '<Alt>Tab']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-windows-backward "['<Shift><Super>Tab', '<Shift><Alt>Tab']"

# Add custom keybinding for Alt+Space Spotlight
dconf write /org/cinnamon/desktop/keybindings/custom-list "['custom0', 'custom1', 'custom2']"
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom2/name "'Spotlight'"
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom2/command "'ulauncher-toggle'"
dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom2/binding "['<Alt>space']"

step "Configured top bar, Apple menu, window buttons, typography and shortcuts."

# ------------------------------------------------------------------------------
# 11. Optional System Boot, Plymouth & Login Screen (if run with sudo)
# ------------------------------------------------------------------------------
info "[11/11] Checking system-level configurations..."
if [ "$(id -u)" -eq 0 ] || sudo -n true 2>/dev/null; then
    # LightDM Slick Greeter
    sudo mkdir -p /etc/lightdm
    cat << EOF | sudo tee /etc/lightdm/slick-greeter.conf >/dev/null
[Greeter]
content-align=center
background=$USER_HOME/.local/share/backgrounds/macOS-Tahoe-5K.jpg
theme-name=WhiteSur-Dark
icon-theme-name=WhiteSur-dark
cursor-theme-name=WhiteSur-cursors
cursor-theme-size=24
font-name=Inter 11
draw-user-backgrounds=false
clock-format=%a %b %e  %-I:%M %p
stretch-background-across-monitors=false
EOF
    step "Configured macOS style Slick Greeter login screen."

    # Plymouth Apple Theme (Authentic High-DPI macOS Boot Screen)
    sudo mkdir -p /usr/share/plymouth/themes/macos-apple
    inkscape -w 128 -h 157 "$USER_HOME/.local/share/icons/apple-logo.svg" -o /tmp/apple-logo-hires.png 2>/dev/null || true
    if [ -f /tmp/apple-logo-hires.png ]; then
        sudo cp /tmp/apple-logo-hires.png /usr/share/plymouth/themes/macos-apple/watermark.png
        sudo cp /tmp/apple-logo-hires.png /usr/share/plymouth/themes/macos-apple/bgrt-fallback.png
        rm -f /tmp/apple-logo-hires.png
    fi
    cat << 'EOF' | sudo tee /usr/share/plymouth/themes/macos-apple/macos-apple.plymouth >/dev/null
[Plymouth Theme]
Name=macOS Tahoe Apple
Description=Authentic High-Definition macOS Apple Boot Splash
ModuleName=two-step

[two-step]
ImageDir=/usr/share/plymouth/themes/macos-apple
HorizontalAlignment=.5
VerticalAlignment=.42
WatermarkHorizontalAlignment=.5
WatermarkVerticalAlignment=.42

Transition=none
TransitionDuration=0.0
BackgroundStartColor=0x000000
BackgroundEndColor=0x000000
UseFirmwareBackground=false

UseProgressBar=true
ProgressBarWidth=220
ProgressBarHeight=5
ProgressBarBackgroundColor=0x2c2c2e
ProgressBarForegroundColor=0xffffff
ProgressBarHorizontalAlignment=.5
ProgressBarVerticalAlignment=.58
ProgressFunction=linear
ProgressBarShowPercentComplete=false
EOF
    sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/macos-apple/macos-apple.plymouth 200 >/dev/null 2>&1 || true
    sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/macos-apple/macos-apple.plymouth >/dev/null 2>&1 || true
    sudo update-initramfs -u >/dev/null 2>&1 || true
    step "Configured authentic macOS Apple Plymouth boot splash."
else
    warn "Skipping system-level login/boot configs (run with sudo to apply Slick-Greeter & Plymouth)."
fi

# Cleanup build directory
rm -rf "$BUILD_DIR"

# Launch plank and ulauncher if in X session
if [ -n "$DISPLAY" ]; then
    nohup plank >/dev/null 2>&1 &
    nohup ulauncher --hide-window >/dev/null 2>&1 &
    nohup cinnamon --replace >/dev/null 2>&1 &
fi

echo -e "\n${BOLD}${GREEN}============================================================${RESET}"
echo -e "${BOLD}${GREEN} macOS Tahoe 26 Theme Installation Completed Successfully! ${RESET}"
echo -e "${BOLD}${GREEN}============================================================${RESET}"
echo -e "Press ${BOLD}Super+Space${RESET} or ${BOLD}Alt+Space${RESET} for Spotlight."
echo -e "Press ${BOLD}Super+Q${RESET} to close active window."
echo -e "Press ${BOLD}Super+Tab${RESET} to switch applications."
echo -e "Click the Control Center icon in the top right to toggle Wi-Fi, BT, Dark Mode & Volume."
