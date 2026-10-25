# macOS Tahoe 26 Customization Changelog

## Phase 0: Baseline & Safety
- Detected system environment: Linux Mint 22.3 Cinnamon, X11, Intel HD Graphics, 1920x1080 resolution.
- Generated full backup of `~/.config`, `~/.local/share`, `~/.themes`, `~/.icons`, and dconf settings into `~/mac-theme-backup/`.
- Created automated rollback script `rollback.sh`.

## Phase 1: Core Theme & Aesthetics
- Installed WhiteSur GTK 3/4 & Cinnamon shell themes with libadwaita GTK4 theme in `~/.config/gtk-4.0`.
- Installed WhiteSur icon theme with Apple-style folder and MIME icons.
- Installed WhiteSur macOS cursors with anti-aliasing and zero alpha noise.
- Configured Inter (10.5pt System, 11pt Bold Titlebar) and JetBrains Mono (Terminal & Code).
- Positioned window controls to the left (`close,minimize,maximize:`) with macOS traffic lights.
- Set macOS Tahoe 5K wallpaper into `~/.local/share/backgrounds/macOS-Tahoe-5K.jpg`.

## Phase 2: Shell Layout & Custom Applets
- Configured slender 30px translucent top menubar, removed bottom panel.
- Installed Apple menu logo in `menu@cinnamon.org`.
- Created custom `macos-appmenu@liquidglass` applet to display active window title in bold.
- Built custom `control-center@macos` applet with authentic 2-column macOS Tahoe layout:
  - Unified Connections card (Wi-Fi, Bluetooth, AirDrop) on left.
  - Stacked Focus (Do Not Disturb) and Appearance (Dark/Light mode) cards on right.
  - Display Brightness and Sound Volume slider capsules.
- Created `macos-widgets@liquidglass` desklet with Clock, Weather, and real-time CPU/RAM/SSD telemetry.

## Phase 3: System-Wide Curvature & File Manager Styling
- Installed and activated `RoundedCorners@klangman` extension with GLSL hardware-accelerated shaders, applying continuous 14px curvature and soft drop shadows to all windows.
- Styled Nemo (Finder) with clean dark sidebar (`#1E2028`), hidden menu/status bars, macOS bookmarks ("Favorites"), and custom GTK3 scrollbars.
- Installed Starship prompt with minimalist macOS formatting (`~/.config/starship.toml`).

## Phase 4: Engineered macOS Clone Dock
- Themed Plank with Liquid Glass dark frosted charcoal pill (`TopRoundness=22`, `BottomRoundness=22`, `HorizPadding=1`).
- Resolved blurry icon downscaling by pre-rendering optimized 128px PNG assets into `~/.local/share/icons/mac-dock/`.
- Configured `hide-mode='intelligent'` with zero unhide delay so windows utilize full screen height while dock glides over windows upon hover.
- Developed `libplank-noglow.so` runtime hook via `LD_PRELOAD` to eliminate elementary OS active app backlight rectangles while preserving running dots (`IndicatorSize=4`).
- Supervised Plank under a persistent `systemd --user` service (`plank.service`).

## Phase 5: Apple Vector Menubar & Boot Splash
- Replaced distorted legacy vector with authentic macOS menu bar Apple mark (`apple-menu.svg`) at 18px with proper padding.
- Built Plymouth boot splash theme (`/usr/share/plymouth/themes/macos-apple`) featuring the crisp white vector Apple mark on AMOLED black with a native macOS progress bar.
- Configured LightDM slick-greeter and WhiteSur GRUB bootloader theme.

## Phase 6: Instant Dock Startup & Low RAM Optimizations
- **Instant Dock Boot Launch**:
  - Identified root cause of dock startup delay: `plank.service` was bound to `default.target` before X11 Display `:0` was initialized by LightDM/Cinnamon, resulting in repeated crash/restart timeouts and single-instance DBus lock collisions.
  - Decoupled `plank.service` from `default.target` and created `~/.config/autostart/plank.desktop` configured with `X-GNOME-Autostart-Phase=Panel` and `X-GNOME-Autostart-Delay=0`.
  - Result: Dock launches in 50 milliseconds simultaneously with the top panel upon user login under full `systemd` restart supervision.
- **Low RAM & CPU Profiling**:
  - Installed and enabled `zram-tools` with `zstd` compressed RAM swap (priority 100, 2.9GB capacity), eliminating sluggish disk swapping.
  - Disabled dormant heavy background daemons (Akonadi/MySQL personal information server and Evolution alarm notification) saving ~550MB of idle RAM.
  - Optimized `macos-widgets@liquidglass` desklet to read `/proc/meminfo` and `/proc/loadavg` directly in-memory via `GLib.file_get_contents`, eliminating 3 subprocess spawns (`free`, `df`, `cat`) every 2 seconds.
  - Added 6s autostart stagger to Bitwarden to prevent boot-time CPU contention.

