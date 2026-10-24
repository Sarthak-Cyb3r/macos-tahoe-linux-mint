#!/bin/bash
set -e

echo "============================================================"
echo " macOS Tahoe 26 -> Original Mint Rollback Script"
echo "============================================================"

# 1. Kill any added services/processes if running
echo "[1/6] Stopping macOS dock & launcher processes..."
killall plank 2>/dev/null || true
killall ulauncher 2>/dev/null || true
killall rofi 2>/dev/null || true
killall picom 2>/dev/null || true

# 2. Restore dconf settings from backup
echo "[2/6] Restoring dconf desktop database..."
if [ -f "$HOME/mac-theme-backup/backup.dconf" ]; then
    dconf load / < "$HOME/mac-theme-backup/backup.dconf"
    echo "  -> dconf successfully restored."
else
    echo "  -> Warning: backup.dconf not found!"
fi

# 3. Restore directories from backup
echo "[3/6] Restoring themes, icons, and configuration folders..."
[ -d "$HOME/mac-theme-backup/dot-themes" ] && rm -rf "$HOME/.themes" && cp -r "$HOME/mac-theme-backup/dot-themes" "$HOME/.themes"
[ -d "$HOME/mac-theme-backup/dot-icons" ] && rm -rf "$HOME/.icons" && cp -r "$HOME/mac-theme-backup/dot-icons" "$HOME/.icons"

# Restore local share items
for d in themes icons cinnamon plank backgrounds; do
    if [ -d "$HOME/mac-theme-backup/local-share/$d" ]; then
        rm -rf "$HOME/.local/share/$d"
        cp -r "$HOME/mac-theme-backup/local-share/$d" "$HOME/.local/share/"
    fi
done

# Restore config items
for d in cinnamon gtk-3.0 gtk-4.0 plank nemo fontconfig rofi kitty ulauncher; do
    if [ -d "$HOME/mac-theme-backup/config/$d" ]; then
        rm -rf "$HOME/.config/$d"
        cp -r "$HOME/mac-theme-backup/config/$d" "$HOME/.config/"
    elif [ -f "$HOME/mac-theme-backup/config/$d" ]; then
        cp "$HOME/mac-theme-backup/config/$d" "$HOME/.config/"
    fi
done

# Clean up added custom applets/desklets if not in backup
rm -rf "$HOME/.local/share/cinnamon/applets/control-center@macos"
rm -rf "$HOME/.local/share/cinnamon/applets/macos-appmenu@liquidglass"
rm -rf "$HOME/.local/share/cinnamon/desklets/macos-widgets@liquidglass"
rm -rf "$HOME/.local/share/plank/themes/Liquid-Glass"
rm -f "$HOME/.local/lib/libplank-noglow.so" "$HOME/.local/lib/libplank-noglow.c" "$HOME/.local/bin/plank"
rm -f "$HOME/.local/share/icons/apple-menu.svg"
systemctl --user disable --now plank.service 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/plank.service"
systemctl --user daemon-reload 2>/dev/null || true
rm -rf "$HOME/.config/ulauncher/user-themes/macOS-Tahoe"

# Remove autostart entries added
echo "[4/6] Removing macOS dock & launcher autostart entries..."
rm -f "$HOME/.config/autostart/plank.desktop"
rm -f "$HOME/.config/autostart/ulauncher.desktop"
rm -f "$HOME/.config/autostart/mac-hotkeys.desktop"
rm -f "$HOME/.config/autostart/picom.desktop"

# Revert starship line in ~/.bashrc if present
if grep -q 'starship init bash' "$HOME/.bashrc"; then
    sed -i '/starship init bash/d' "$HOME/.bashrc"
    echo "  -> Cleaned starship prompt from ~/.bashrc"
fi

# 4. Explicit fallback for core gsettings to ensure clean panel & theme restoration
echo "[5/6] Ensuring core Cinnamon interface settings are restored..."
gsettings set org.cinnamon.desktop.background picture-uri 'file:///home/sarthak/Downloads/1371390%20(1).jpeg' 2>/dev/null || true
gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-L-Dark-Blue' 2>/dev/null || true
gsettings set org.cinnamon.desktop.interface icon-theme 'MacTahoe-dark' 2>/dev/null || true
gsettings set org.cinnamon.desktop.interface cursor-theme 'Bibata-Modern-Classic' 2>/dev/null || true
gsettings set org.cinnamon.desktop.interface font-name 'Ubuntu 10' 2>/dev/null || true
gsettings set org.cinnamon.desktop.wm.preferences titlebar-font 'Ubuntu Bold 10' 2>/dev/null || true
gsettings set org.cinnamon.desktop.wm.preferences button-layout ':minimize,maximize,close' 2>/dev/null || true
gsettings set org.cinnamon.theme name 'Mojave-Dark-blue' 2>/dev/null || true
gsettings set org.cinnamon panels-enabled "['1:0:bottom']" 2>/dev/null || true
gsettings set org.cinnamon panels-height "['1:40']" 2>/dev/null || true
gsettings set org.cinnamon enabled-desklets "[]" 2>/dev/null || true
gsettings set org.cinnamon enabled-applets "['panel1:left:0:menu@cinnamon.org:0', 'panel1:left:1:show-desktop@cinnamon.org:1', 'panel1:left:2:grouped-window-list@cinnamon.org:2', 'panel1:right:0:systray@cinnamon.org:3', 'panel1:right:1:xapp-status@cinnamon.org:4', 'panel1:right:2:notifications@cinnamon.org:5', 'panel1:right:3:printers@cinnamon.org:6', 'panel1:right:4:removable-drives@cinnamon.org:7', 'panel1:right:5:keyboard@cinnamon.org:8', 'panel1:right:6:favorites@cinnamon.org:9', 'panel1:right:7:network@cinnamon.org:10', 'panel1:right:8:sound@cinnamon.org:11', 'panel1:right:9:power@cinnamon.org:12', 'panel1:right:10:calendar@cinnamon.org:13', 'panel1:right:11:cornerbar@cinnamon.org:14']" 2>/dev/null || true

# 5. System level configs (GRUB, Plymouth, LightDM)
if [ "$(id -u)" -eq 0 ] || sudo -n true 2>/dev/null; then
    echo "[6/6] Restoring system level boot & greeter configs..."
    # LightDM Slick Greeter
    if [ -f "/etc/lightdm/slick-greeter.conf" ]; then
        sudo rm -f /etc/lightdm/slick-greeter.conf
        echo "  -> Reset Slick Greeter configuration."
    fi
    # GRUB
    if [ -f "/etc/default/grub.bak" ]; then
        sudo cp /etc/default/grub.bak /etc/default/grub
        sudo update-grub 2>/dev/null || true
        echo "  -> Restored original GRUB configuration."
    fi
    # Plymouth
    if [ -f "/usr/share/plymouth/themes/mint-logo/mint-logo.plymouth" ]; then
        sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/mint-logo/mint-logo.plymouth 2>/dev/null || true
        sudo update-initramfs -u 2>/dev/null || true
        echo "  -> Restored default Linux Mint boot splash."
    fi
    # Clean temporary sudoers file if present
    if [ -f "/etc/sudoers.d/customization" ]; then
        sudo rm -f /etc/sudoers.d/customization 2>/dev/null || true
    fi
else
    echo "[6/6] Skipping root bootloader/splash restore (run with sudo if desired)."
fi

# 6. Restart Cinnamon
echo "Restarting Cinnamon shell..."
DISPLAY=:0 nohup cinnamon --replace >/dev/null 2>&1 &

echo "============================================================"
echo " Rollback completed! Desktop restored to original state."
echo "============================================================"
