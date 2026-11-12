# SYSTEM INIT DOCUMENTATION

## System Specsheet:
OS: openSUSE Tumbleweed x86_64
Display (LG ULTRAGEAR): 1920x1080 in 24", 180 Hz
WM: Sway 1.12 (Wayland)
CPU: AMD Ryzen 7 9700X (16) @ 5.58 GHz
GPU 1: AMD Radeon RX 9070 XT [Discrete]
GPU 2: AMD Radeon Graphics [Integrated]
MOBO: Gigabyte B850M Gaming X WiFi6E
MEMORY: 32Gib

## System Modification Log:
- BIOS:
    Disabled Secure Boot
    Enabled XMP Profile 1 — DDR5-5600 40-40-40-89; memory went 4800 → 5603 MT/s
    Set Boot Option #1 to the Kingston USB, from windows bootloader
- Tumbleweed Installation:
    System Role: Generic Desktop
    Guided Setup partitioning: Windows and other partitions set to "Remove even if not needed"
    No LVM, no disk encryption
    Btrfs with snapshots, no separate /home, 2GB swap without hibernate sizing
    Switched bootloader from systemd-boot to GRUB2 EFI for snapshot rollback
    sway confirmed absent from the DVD; selected git, vim, curl, wget, wpa_supplicant, NetworkManager-tui
    Kept X Window System + IceWM as fallback
    Installed, ~928GB root, Windows fully removed
- System Init:
    zypper dup blocked by the stale DVD repo pointing at dm-name-ventoy; removed it, dup completed*
    Installed sway, foot, waybar, wofi
    sway absent from the login screen — display manager was X-only
    Installed SDDM and set it as display manager
    Still landing in IceWM; autologin — DISPLAYMANAGER_AUTOLOGIN="ocx" was bypassing the greeter; cleared it
    Logged into sway via SDDM
    Installed: MozillaFirefox, zsh, git, neovim, fzf, zoxide, eza, ripgrep, fd, bat, btop, tmux, unzip, wl-clipboard, grim, slurp, swaybg, swayidle, swaylock, waybar, wofi, mako, wlr-randr, ghostty, xdg-desktop-portal-wlr
    Confirmed: Wayland session, PipeWire 1.6.8, snapper snapshots active, 928.59 GiB root
    Found the monitor was plugged into the motherboard; Moved the DisplayPort cable to the RX 9070 XT- changed to DP-2
    Installed libvulkan_radeon — Vulkan had been falling back to llvmpipe
    Verified: RX 9070 XT (radeonsi, gfx1201) and RADV GFX1201

- Desktop (Aug 2026):
    Cloned dotfiles; ~/.config/{sway,waybar,rofi,ghostty,fastfetch,dunst,swaylock} and ~/.zshrc are symlinks into ~/.dotfiles
    Ported the i3 config to sway: Mod4, app_id rules for Wayland windows, grim/slurp screenshots, ddcutil brightness keys
    Output: DP-2 1920x1080@180Hz with adaptive_sync on
    Replaced wofi with rofi (launcher sits over the top bar; dropdown.rasi for the bar menus)
    Waybar: two bars, greyscale theme, polybar scripts ported (workspaces, updates, weather, wifi, bt, power, nowplaying, volume, brightness)
    Ghostty: colours/fonts split into their own files, ctrl+c/ctrl+v copy-paste
    zsh: powerlevel10k, eza/bat aliases, zoxide, fzf, autosuggestions, syntax highlighting
    Enabled Packman; installed Steam, gamescope, mangohud, libvulkan_radeon-32bit
    xdg-user-dirs set up
- Desktop (Oct-Nov 2026):
    sway: gaps inner 6 → 3; ctrl+space opens rofi, $mod+space opens the terminal
    sway: autostart.sh — dunst, autotiling-rs, udiskie, gammastep, mpd, polkit-gnome agent; pasystray in the tray
    sway: session env imported into systemd/dbus, sway-session.target started
    sway: wallpaper set from wallpapers/wallpaper.jpg
    sway: Content Manager window of steam_app_244210 floats at full size
    rofi: font 10.25 at fixed 96 dpi, x-offset 0, inputbar padding tuned to the bar
    waybar: plain λ in the window module, steamwebhelper shown as steam
    ghostty: removed fixed window-width/height
    zsh: ssh-agent on $XDG_RUNTIME_DIR/ssh-agent.socket, 12h key lifetime, no prompt at shell start
    fastfetch: opensuse logo, green/grey colours
    waybar: bottom-right order is now volume, brightness, ✧, tray (tray at the edge); no separator between volume and brightness
    waybar: process count module first in the bottom centre (ps -e count, every 5s); click opens btop in ghostty
    waybar: clicking the bottom-bar wifi module opens a rofi network menu above it (rofi/dropup.rasi); hover tooltip removed
    wifi menu: networks sorted by signal with strength icons, Rescan entry, click to connect/disconnect; new secured networks ask for the password in rofi (no more nmtui window); result shown via dunstify
    rofi menus: added -sync in _rofi_engine.sh — rofi-wayland 1.7.9 segfaulted on every bar menu (wifi, bt, weather, power) because the inputbar-less menu started at zero height
    _rofi_engine.sh: ROFI_THEME env var picks dropdown.rasi (top bar, default) or dropup.rasi (bottom bar)
    dunst: new dunst/dunstrc, ~/.config/dunst symlinked to it — black popups in the bottom-left corner above the bar, 1px grey frame (brighter for critical), JetBrainsMono 10; left click closes, right click closes all
    waybar: brightness icon changed to the brightness sun (nf-md-brightness_7) so it no longer matches the weather sun
    waybar: clicking the λ + app name module (top left) opens the rofi launcher, same as ctrl+space
    waybar: cpu module — hover tooltip removed; click opens a rofi panel (waybar/scripts/cpu-module.sh, rofi/dropdown-left.rasi) with total usage bar, temp, frequency, load, per-core bars (first version also had the model name, top 3 processes and an Open btop entry)
    waybar: cpu panel trimmed to usage, temp, freq, load and per-core bars (no model name, processes or btop entry); opens instantly — a hidden custom/cpusnap module snapshots /proc/stat every second so no sampling wait is needed
    waybar: memory module — click opens a small rofi menu (waybar/scripts/mem-module.sh) with ram and swap bars, free and cache; hover tooltips removed from memory, temperature and updates
    waybar: window module shows "λ ocx" when nothing is focused (empty workspace)
    waybar: clicking the updates count opens ghostty with the pending update list (zypper lu) and a y/N prompt to run sudo zypper dup; the count refreshes afterwards (signal 8)
    waybar: removed the wifi status module from the top bar; its access-point icon now sits before the wifi name on the bottom bar (the bottom module's click menu replaces it)
    waybar: bottom-bar wifi module shows signal strength (%) instead of the network name; "offline" when disconnected
    waybar: wifi module no longer vanishes when the wifi radio is off — format-disabled added, so it shows "offline" and stays clickable; offline uses the same access-point icon
    wifi menu: opens instantly from NetworkManager's cached scan (--rescan no) and refreshes the scan in the background; only the Rescan entry waits for a fresh scan
    waybar: hover tooltip removed from the window (λ) module
    waybar: temperature removed from the cpu click panel (the bar already shows it)
    waybar: click menus toggle — clicking the same module again closes its rofi menu; clicking another module swaps to that menu (handled in _rofi_engine.sh, launcher click included)
    waybar: clock is 12h with AM/PM, hover calendar removed, click opens renCal
    waybar: weather module — 3-day rofi forecast and hover tooltip removed; icon matching fixed (thunder/snow now win over rain in combined conditions; sleet, blizzard, hail, haze, smoke, dust added; error pages from wttr.in no longer shown as weather)
    waybar: clicking the weather module opens Mousam (flatpak io.github.amit9838.mousam)
    waybar: bluetooth module — hover tooltip removed; menu rewritten like the wifi one: power toggle, Scan (6 s, then reopens), connected / paired / new devices, click to connect, disconnect or pair+trust+connect, results via dunstify; every bluetoothctl call is time-boxed
    rofi: dropdown.rasi now anchors to the top-right corner flush under the bar (was a fixed 1510px offset with a 28px gap), used by the bluetooth and power menus
    Found: bluez is not installed (adapter hci0 exists), so the bluetooth module shows "off" and the menu says so until it is
    Installed bluez, bluetooth.service running; bar menu tested: power on/off, scan, status icons (device rows and pair/connect actions only against a stub — no named device was in range)
    waybar: now-playing scrolls long titles as a marquee in bursts — holds the start 3 s, slides 4 chars/s to the end, holds 2 s, restarts; 40-char window; nowplaying.sh now runs continuously instead of on a 3 s interval; markup in titles is escaped
    waybar: power menu icon changed to 󱄚 (U+F111A)
    waybar: power button moved to the far left of the bottom bar, followed by a grey vertical line before the music module; its menu opens upward from the corner (rofi/dropup-left.rasi); bluetooth is now the last module on the top bar
    waybar: tray moved from the bottom-right to the top-right edge, after bluetooth (✧ between them); bottom bar now ends with volume and brightness
    swaylock: new swaylock/config (~/.config/swaylock symlinked) — black screen, thin grey ring always visible, JetBrainsMono, lighter ring for verifying / wrong / caps lock; sway/lock.sh added, so $mod+l and the power menu's Lock entry now work
    swaylock restyled: background is the wallpaper frosted (blurred), colour-muted and darkened, with "λ user" under the ring — built by sway/lock.sh with ImageMagick and cached in ~/.cache/swaylock/bg.jpg (rebuilt when the wallpaper or script changes; lock.sh --rebuild forces it); ring is larger and thicker over a smoked-glass disc, bright while verifying, inverted on a wrong password
    swaylock: "λ user" label removed from the lock background; ring changed to a 3px hairline with no disc (white segment on key press, solid white while verifying, light haze inside on a wrong password)
    swaylock: ring is now a thin blue accent (#86a4dc, from the wallpaper) over a dark glass disc — option D of four mock-ups
    swayidle: started from sway/autostart.sh — lock after 10 min idle, screen off at 11 min (back on at input), lock before suspend; fullscreen windows inhibit idle (sway/config)
    zsh: SUDO_ASKPASS and SSH_ASKPASS point at ~/.local/bin/zenity-askpass (zenity --password); the default gnome-ssh-askpass cannot open its dialog here because the GNOME prompter service is not installed
    sway: Steam starts with the session (steam -silent — tray only, no main window)
    waybar: back button left of the now-playing text, play-pause and skip right of it (waybar/scripts/music-module.sh, playerctl with mpd fallback); hidden when nothing plays
    waybar: clicking the now-playing text opens a dropup showing just the cover art (rofi/music.rasi); remote covers are cached in ~/.cache/nowplaying
    _rofi_engine.sh: ROFI_ARGS array is passed straight to rofi (-mesg, extra -theme-str)
    fonts: SF Pro (from the Mac) unzipped into ~/.local/share/fonts/SF-Pro — Apple-licensed, kept out of this repo; waybar needs a full restart to see a new font
    waybar: workspaces module shows one constant SF Symbols icon per workspace (scripts/workspace-icons.txt, same set as aeromenu on macOS) — focused workspace uses its second glyph at the centre, the others are dimmed; workspaces without an icon show their name
    sway: Bitwarden windows float
    dunst: notifications appear bottom-right (was bottom-left)
    waybar: do-not-disturb toggle at the right end of the bottom bar (scripts/dnd-module.sh) — pauses dunst; held notifications appear when it is switched off
    waybar: caffeine toggle next to it (scripts/caffeine-module.sh) — while on, the swayidle lock and screen-off timeouts in sway/autostart.sh are skipped; resets on reboot, lock-before-suspend unaffected
    waybar: workspace icons can carry a colour (optional 4th column in scripts/workspace-icons.txt) — workspace 1 is orange #FF9F0A, workspace 2 teal #007A74; a coloured icon stays coloured but fainter when unfocused
    bin/ws-color: CLI to set a workspace icon colour — "ws-color" lists, "ws-color 3 ff9f0a" sets, "ws-color 3 none" clears, "ws-color rand" / "ws-color 3 rand" picks random colours; symlinked into ~/.local/bin, reloads waybar
    waybar: focused workspace icon sits in [ brackets ]; wider gap between workspace icons; icons 9pt
    waybar: the [ ] brackets stay fixed at the centre — each side is padded with invisible copies of the other side's icons so the widths match exactly; the slide animation is gone (it moved the brackets)
    waybar: clicking the volume slider opens a mixer dropup (scripts/audio-module.sh, rofi/dropup-right.rasi) listing every application playing sound — Enter picks a level or mutes, Left / Right changes the selected one by 5%. Mute moved to right click
    _rofi_engine.sh: ROFI_EXIT carries rofi's exit code (custom keys)
    _rofi_engine.sh: ROFI_LINES env var raises the row limit for long menus

## Repo Layout:
    sway/        config, autostart.sh
    bin/         ws-color (workspace icon colours); ln -s into ~/.local/bin
    waybar/      config.jsonc, style.css, scripts/ (rofi menus go through _rofi_engine.sh)
    rofi/        config.rasi (launcher), dropdown.rasi / dropdown-left.rasi / dropup.rasi / dropup-left.rasi / dropup-right.rasi (top-right / top-left / bottom-centre / bottom-left / bottom-right bar menus), music.rasi (cover-art dropup), colors.rasi
    ghostty/     config, colors, fonts
    zsh/         .zshrc
    fastfetch/   config.jsonc
    dunst/       dunstrc (notifications)
    swaylock/    config (lock screen)
    p10k/        powerlevel10k checkout
    wallpapers/  wallpaper.jpg
Palette: background #070708, foreground #e3e2e9, accent #BABAC6, dim #7C7C84, border #4D4D5A. Font: JetBrainsMono Nerd Font.

## Keybinds (sway):
    $mod = Super
    ctrl+space            rofi launcher
    $mod+space / Return   ghostty
    $mod+q                kill window
    $mod+arrows           focus; +Shift to move
    $mod+1..0             workspace; +Shift to move the window there
    $mod+f / s / w / e    fullscreen / stacking / tabbed / toggle split
    $mod+h / v / t        split horizontal / vertical / toggle
    $mod+Shift+space      floating toggle
    $mod+r                resize mode
    $mod+Shift+s          region screenshot to clipboard
    $mod+Shift+a / f      region / full screenshot to ~/Pictures/screenshots
    $mod+l                lock screen (swaylock)
    $mod+F1 / F2          monitor brightness down / up (ddcutil)
    $mod+F4 / F9          firefox / ncmpcpp
    $mod+Shift+c          reload config
    $mod+Shift+e          exit sway
    $mod+Shift+F6         reboot

## Workflow:
    Every change is committed per component ("sway: ...", "waybar: ...") and logged in the Modification Log above.
    Ricing goals live in the TODO below; finished items move to the log.

## TODO:
- Ricing:
    - $mod+F6 calls sway/scripts/power-menu.sh, which does not exist — point it at waybar/scripts/power-module.sh
    - $mod+F7/F8 wifi and bluetooth menus — bind to the waybar scripts
    - Lock screen has no clock (plain swaylock cannot draw one) — hyprlock or gtklock from the repo could
    - zsh/p10k-colors.zsh is sourced but missing; ~/.p10k.zsh lives outside the repo
    - p10k is a gitlink without .gitmodules — make it a real submodule or install it another way
    - Waybar temperature uses a fixed hwmon4 path that can shift between boots
    - Clean out leftover Polybar/Alacritty comments in the scripts
    - Bottom-bar uptime module shows nothing: this uptime has no -p option
    - mako is installed but unused now that dunst is configured — uninstall it
    - wallpaper.jpg is 30MB — compress it or keep it out of git
- System:
    - Bluetooth: pair and connect a real device through the bar menu (only tested against a stub so far)
    - 32-bit graphics libs: Mesa-libGL-32bit Mesa-libEGL-32bit (libvulkan_radeon-32bit done)
    - Set the hostname — still localhost
    - BIOS: Above 4G Decoding + Resizable BAR, SVM Mode, PBO or 105W cTDP
    - Optionally re-enable Secure Boot
    - Remove leftover /boot/efi/EFI/Microsoft and regenerate grub.cfg
    - Confirm native resolution — currently 1080p180, panel also offers 1440p75
    - Ethernet enp10s0 still shows no link — cable or router
    - rpm -V vulkan-tools — reported an error on install
