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
    waybar: workspace icons can carry a colour (optional 4th column in scripts/workspace-icons.txt, set with ws-color) — shown only while that workspace is focused; unfocused icons are all grey
    bin/ws-color: CLI to set a workspace icon colour — "ws-color" lists, "ws-color 3 ff9f0a" sets, "ws-color 3 none" clears, "ws-color rand" / "ws-color 3 rand" picks random colours; symlinked into ~/.local/bin, reloads waybar
    waybar: focused workspace icon sits in [ brackets ]; wider gap between workspace icons; icons 9pt
    waybar: the [ ] brackets stay fixed at the centre — each side is padded with invisible copies of the other side's icons so the widths match exactly; the slide animation is gone (it moved the brackets)
    waybar: brightness, do-not-disturb and caffeine icons are SF Symbols now, drawn at 10pt — toggles show the empty variant when off and the filled one when on; the volume slider keeps its original music-note icon; caffeine cup nudged down 3px in style.css
    waybar: no hover tooltip on the volume and brightness sliders
    waybar: brightness icon 8pt, closer to its slider and lifted onto the slider line; do-not-disturb icon 11pt, nudged down 1px (style.css)
    waybar: the power button is the current moon phase (SF Symbols moonphase set, computed from the date in power-module.sh --icon, refreshed hourly); click still opens the power menu; 13px from the left edge
    waybar: external-drive module on the bottom bar, after the separator (scripts/drive-module.sh) — filled icon while a USB / hot-plug drive is connected; click opens a dropup to eject (unmount + power off via udisksctl) or mount
    waybar: network icon moved into its own module (custom/netstate, wifi-module.sh --icon) — shows the "no internet" glyph when NetworkManager's connectivity is anything but full (offline, or router up but internet down)
    waybar: bluetooth icon is one constant SF Symbols glyph; it no longer changes with the adapter state
    waybar: drive, do-not-disturb, caffeine and bluetooth icons one step smaller (9pt / 10pt / 9pt / 9pt)
    xdg: XDG_DESKTOP_DIR set to ~/Desktop (was $HOME); Downloads / Documents / Music / Pictures / Videos / Projects unchanged
    system: removed thunar, thunar-volman, thunar-archive-plugin and their lang / branding packages; MozillaThunderbird was already installed
    waybar: external-drive icon nudged down 2px (style.css)
    waybar: tray icons nudged down 2px so they sit on the text line, 12px from the right edge (style.css)
    ghostty: colour palette — muted pastels instead of sixteen greys (ghostty/colors), so ls, git, bat and fzf output is coloured
    zsh: fastfetch runs at the top of every new terminal (before the p10k instant prompt), followed by an empty line; prompt colours in zsh/p10k-colors.zsh (blue directory, green / yellow git, magenta / red prompt character); coloured completion lists with group headings; bat and fzf follow the terminal palette; AUTO_CD and comments at the prompt
    fastfetch: added a module list — without one this version printed only the logo; keys coloured blue
    fastfetch: laid out as three colour-coded groups (system blue, desktop magenta, hardware green) with icon + lowercase keys in an aligned column and a row of palette dots
    ghostty: colour scheme is the built-in theme "Belafonte Night" (theme line in ghostty/colors; browse with ghostty +list-themes; reload a running Ghostty with pkill -USR2 -x ghostty); prompt colours in zsh/p10k-colors.zsh re-matched to it
    zsh: prompt restyled as powerline blocks (zsh/p10k-colors.zsh, on top of ~/.p10k.zsh) — blue folder block, git block (olive clean / amber changed) with ahead, staged, modified and untracked counts; status, duration and clock blocks on the right; prompt character alone on the second line
    system: build tools and -devel packages installed for SwayFX (gcc, meson, ninja, scdoc, wlroots-devel, wayland / cairo / pango / libinput / libdrm / Mesa EGL+GLES / xcb devel ...)
    swayfx: tried SwayFX 0.6 (built from source) for blur, shadows and rounded corners, then rolled it back as unstable — binary, sources, session entry and its config files are removed; the build tools and -devel packages are still installed (picom is X11-only and cannot run under sway)
    sway: effects that plain sway can do — the focused window is solid and unfocused windows are 95% opaque (sway/inactive-opacity.sh, started from the config); no blur, shadows or rounded corners
    sway: waybar now starts at login — the old "exec_always pkill waybar; waybar" line was split at the ; by sway, so waybar itself was never launched; replaced by sway/waybar.sh (also restarts the bars on config reload)
    waybar: workspace icons 6 and 7 swapped
    nvim: default editor everywhere — EDITOR / VISUAL=nvim in .zshrc and environment.d/editor.conf (symlinked into ~/.config/environment.d); applications/nvim-ghostty.desktop ("ghostty -e nvim %F", symlinked into ~/.local/share/applications) is the xdg default for text, source-code, config and script file types; HTML still opens in Firefox
    sddm: macOS-style login theme "glass" (sddm/theme/, plain QtQuick 2 — the Qt5 greeter here has no Controls / GraphicalEffects modules): sharp photo background, date and large clock on top, round profile picture + name + frosted password pill, Sleep / Restart / Shut Down buttons, session name bottom-right (click to switch)
        install: sddm/install.sh — copies SF Pro Display from ~/.local/share/fonts (not in the repo), cuts ~/Pictures/pfp.png into a round avatar, installs to /usr/share/sddm/themes/glass, writes /etc/sddm.conf.d/10-theme.conf, and makes the theme's backgrounds/ folder owned by the user; re-run after changing the theme or the profile picture
        photo:   sddm/wallpaper.sh replaces backgrounds/current.jpg and caption.txt — Wikimedia Commons Picture of the Day with its English caption (Bing photo of the day as fallback); run every six hours by systemd/login-wallpaper.timer (user units, symlinked into ~/.config/systemd/user)
        layout:  power buttons top-left, photo caption bottom-centre, small password pill (140x24), no placeholder text in it
        preview: sddm-greeter --test-mode --theme ~/.cache/sddm-glass   (after sddm/install.sh --build-only; it opens full screen and grabs the keyboard — close it with pkill sddm-greeter)
    lock: hyprlock replaces swaylock as the lock screen (hyprlock/hyprlock.conf, symlinked to ~/.config/hypr/) — same photo, caption, clock, profile picture and password pill as the login screen; sway/lock.sh starts it and falls back to swaylock if hyprlock is missing
    nvim: full config in nvim/ (symlinked to ~/.config/nvim), lazy.nvim plugin manager, leader = Space
        theme:    Kanagawa (wave)
        plugins:  fzf-lua (find files / grep), neo-tree (file tree), nvim-treesitter (highlighting, 28 parsers), gitsigns, lualine, which-key, indent guides, mini.pairs, mini.surround, todo-comments, blink.cmp (completion), conform (format on save)
        servers:  Mason installs lua_ls, basedpyright + ruff, ts_ls, html, cssls, jsonls, clangd, rust_analyzer, bashls, yamlls, taplo, marksman; tools: stylua, prettier, shfmt, shellcheck
        new machine: start nvim once (plugins install themselves), then :MasonInstall happens automatically for the servers; needs git, gcc, node/npm, python3, tree-sitter CLI
    sway: window borders 3px black on the focused window only; unfocused windows keep the space but the border is transparent (none at all on Firefox / LibreWolf)
    zsh: plugins — autosuggestions, syntax highlighting, history substring search (Up / Down) and fzf-tab (Tab completions in an fzf popup). Not packaged by openSUSE: zsh/install-plugins.sh clones them into ~/.local/share/zsh/plugins (run it once on a new machine, again to update); .zshrc skips any that are missing
    waybar: clicking the volume slider opens a mixer dropup (scripts/audio-module.sh, rofi/dropup-right.rasi) listing every application playing sound — Enter picks a level or mutes, Left / Right changes the selected one by 5%. Mute moved to right click
    _rofi_engine.sh: ROFI_EXIT carries rofi's exit code (custom keys)
    _rofi_engine.sh: ROFI_LINES env var raises the row limit for long menus
    bin/ws-swap: CLI to swap the icons of two workspaces on the top bar — "ws-swap" lists, "ws-swap 6 7" trades the icons (colours travel with them), "ws-swap -k 6 7" trades the icons but keeps each workspace's colour; edits scripts/workspace-icons.txt, symlinked into ~/.local/bin, reloads waybar
    theme: GTK and Qt programs now follow the bar — background #070708, text #e3e2e9, accent #BABAC6, 1px #4D4D5A borders, square corners, selected rows inverted as in rofi; set up by theme/install.sh (run once on a new machine)
        packages: sudo zypper install kvantum-qt5 kvantum-qt6 kvantum-themes qt5ct qt6ct papirus-icon-theme
        GTK 3:    adw-gtk3-dark v6.5 (downloaded into ~/.local/share/themes, not packaged by openSUSE) recoloured by theme/gtk.css
        GTK 4:    libadwaita recoloured by theme/gtk4.css (imports gtk.css; the accent has to be set as CSS variables there)
        Qt 5 / 6: Kvantum theme "Mizu" (kvantum/Mizu) picked through qt5ct / qt6ct; its widget pieces are drawn by kvantum/build-svg.py — change a colour there and run it again. QT_QPA_PLATFORMTHEME=qt5ct comes from environment.d/qt.conf, so programs started from the launcher are themed after the next login. Qt 5 programs run through XWayland (no Qt 5 Wayland plugin installed)
        icons:    Papirus-Mizu = Papirus-Dark with grey folders, built into ~/.local/share/icons by the install script
        fonts:    SF Pro Text 11 for interfaces, JetBrainsMono Nerd Font 11 for code (gsettings + qt5ct / qt6ct)
        colour:   the only hues are muted red / yellow / green for delete buttons, warnings and success; radio buttons stay round so they differ from check boxes
        flatpak:  user override lets flatpak programs read the GTK theme files and icons (flatpak override --user --show)
        PrismLauncher: ApplicationTheme=system in ~/.local/share/PrismLauncher/prismlauncher.cfg (was its built-in "dark"), so it uses the Qt theme
        checked:  test windows for GTK 3, GTK 4, Qt 5 and Qt 6 plus PrismLauncher, Konsole and lxqt-archiver rendered in a headless sway
- System Tuning (2026-11-13 / 14):
    wifi: lag spikes in Deadlock and PoE2 (60 → 150 ms, rubber-banding) traced to Wi-Fi power saving on the RTL8852CE (rtw89 driver) — not the ISP, not waybar, not Bluetooth
        measured: ping to the router 192.168.0.1 was 23–52 ms avg, 230–570 ms spikes, 2–14% loss (2.4 and 5 GHz alike); with power saving off 0.8 ms avg, 5.5 ms max, 0% loss
        fix:      /etc/NetworkManager/conf.d/wifi-powersave-off.conf — [connection] wifi.powersave = 2; then systemctl restart NetworkManager
        check:    iw dev wlp9s0 get power_save → "Power save: off";  ping -c 150 -i 0.2 -q 192.168.0.1
        5 GHz:    nmcli con modify <5 GHz network> connection.autoconnect-priority 10 — preferred over the crowded 2.4 GHz <2.4 GHz network> (channel 2)
    hostname: mizu (hostnamectl set-hostname mizu; was localhost)
    32-bit graphics: nothing to install — the packages are named Mesa-libGL1-32bit / Mesa-libEGL1-32bit here (with a 1) and are present, along with Mesa-32bit, Mesa-dri-32bit, libvulkan1-32bit and libvulkan_radeon-32bit
    vulkan-tools: rpm -V vulkan-tools is clean now
    display: 1920x1080 @ 180 Hz confirmed as the panel's native mode — the EDID's preferred timing is 1080p180 on a 527x296 mm (24") panel; 2560x1440 @ 75 is a scaled-up "virtual" mode the monitor offers, so sway/config stays as it is
    Windows leftovers removed (2026-11-14):
        sudo rm -rf /boot/efi/EFI/Microsoft              — old Windows boot files (Boot, Recovery) on the EFI partition
        sudo efibootmgr -b 0000 -B                       — firmware entry "Windows Boot Manager"; boot order is now 0002 (opensuse-secureboot), 0001
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg      — GRUB menu regenerated: kernels 7.3.3 and 7.2.9 + UEFI Firmware Settings, no Windows entry
        left alone: nvme0n1p2 (16 MB Microsoft reserved) and nvme0n1p4 (730 MB NTFS recovery) — harmless, and too small to be worth repartitioning
    zypper dup → Tumbleweed 20261111: 32 packages, all Mesa / Vulkan packages (64- and 32-bit) now on 26.2.6; also ffmpeg libs, xwayland 24.1.14, dracut
    BIOS, verified from Linux (no change needed):
        Above 4G Decoding + Resizable BAR: on — the RX 9070 XT exposes a 16 GB BAR (/sys/bus/pci/devices/0000:03:00.0/resource)
        SVM Mode: on — /dev/kvm exists
- Desktop QoL — fonts, Firefox, network (2026-11-15):
    audit: what was checked, and what turned out to need nothing
        fonts:    only Latin / Greek / Cyrillic were covered — Hindi and the other Indian scripts, Chinese / Japanese / Korean, Arabic, Hebrew and Thai had no font at all (empty boxes in Firefox); emoji (Noto Color Emoji) was already there. Fixed below
        firefox:  the profile (~/.config/mozilla/firefox/zasqhewv.default-release) had no user.js and no userChrome — sites break because of stacked extensions, mostly Popup Blocker Ultimate, which switches off every popup opened by a click (login and payment windows), plus CanvasBlocker, Cookie AutoDelete and four more trackers-blockers on top of uBlock Origin
        video:    H.264 / AAC play (ffmpeg libraries from packman), Widevine DRM is on, OpenH264 present
        portals:  xdg-desktop-portal, -wlr and -gtk all running (file chooser, screen sharing)
        network:  router ping 0.8 ms avg, 0% loss; DNS (8.8.8.8 from the router) answers in 6 ms; clock synced by chrony; firewalld active, Wi-Fi in the "public" zone; no IPv6 from the ISP
    fonts: installed — sudo zypper install google-noto-fonts google-noto-sans-cjk-fonts google-carlito-fonts google-caladea-fonts myspell-en_US myspell-en_GB myspell-hi_IN
        google-noto-fonts = every script except Chinese / Japanese / Korean; carlito / caladea stand in for Calibri / Cambria in documents; myspell = spell-check dictionaries (English, Hindi)
        check:  fc-match :lang=hi → Noto Sans Devanagari;  fc-match :lang=ja → Noto Sans CJK JP
    clock: hardware clock moved from local time (a Windows leftover) to UTC — sudo timedatectl set-local-rtc 0
    firefox extensions removed in about:addons — they, not a user.js, were what broke sites:
        broke sites:  Popup Blocker Ultimate (switched off every popup opened by a click), PopUpOFF, Quick Redirect Blocker, CanvasBlocker, Cookie AutoDelete
        duplicated uBlock Origin / Firefox's own protection:  Ghostery, Privacy Badger, Disconnect, Decentraleyes, ClearURLs, Reddit Ad Remover
    sway: autostart.sh started the polkit agent from /usr/lib/…, which does not exist — it lives in /usr/libexec/polkit-gnome-authentication-agent-1. Password prompts for firewall-cmd, mounting, etc. never appeared ("Authorization failed"); fixed
    firefox: firefox/user.js, symlinked into the profile — strict tracking protection stays, with Mozilla's two exception lists for sites known to break under it (the "convenience" one had been switched off)
        new machine: ln -s ~/.dotfiles/firefox/user.js ~/.config/mozilla/firefox/<profile>/user.js; takes effect at the next Firefox start
    image viewer: Gwenview (sudo zypper install gwenview) is the default for image files — png, jpeg, webp, gif, svg, avif, heif, jxl, tiff, bmp, ico and the rest (xdg-mime default org.kde.gwenview.desktop …, stored in ~/.config/mimeapps.list); they opened in Chromium before
    theme: KDE programs are in the palette too — theme/Mizu.colors, a KDE colour scheme, linked into ~/.local/share/color-schemes and copied into ~/.config/kdeglobals by theme/install.sh
        why:     programs built on KDE's libraries take view backgrounds and icon colours from kdeglobals, not from the Qt style; without it Gwenview had a white picture area and dark-on-black toolbar icons
        also:    [KDE] contrast=0 in kdeglobals — KDE computes its "mid" grey from the window colour, and the default made Gwenview's location bar #6B6B72; now #202024
        checked: Gwenview's view and browse modes rendered in a headless sway
    media player: VLC 3.0.24 from Packman (sudo zypper install --from packman vlc vlc-codecs) is the default for audio and video files — all 134 audio/*, video/* and container types in vlc.desktop (xdg-mime default vlc.desktop …)
        theme:   VLC is a Qt 5 program, so menus, buttons and dialogs already come from Kvantum "Mizu"; the seek bar and the volume control were its own blue and green-to-red drawings
        fix:     vlc/vlc-qt-interface.conf — the toolbar layouts with the "shiny" flag (-4) removed from the seek slider (33) and the volume control (35), so both are plain theme sliders; same as Tools → Customise Interface → "Native Slider"
        also:    vlc/vlcrc — no first-run privacy question, no fetching of cover art / metadata from the network
        new machine: cp ~/.dotfiles/vlc/* ~/.config/vlc/ before the first start (copies, not links: VLC rewrites both files with window size and recent files)
        left:    VLC's toolbar icons are built-in dark-grey pictures, dim on the black bar; VLC 3 cannot take them from the icon theme
        checked: main window with a file open, rendered in a headless sway (XWayland)
    archiver: extra back-ends for lxqt-archiver — sudo zypper install lz4 lzop lzip lrzip arj lhasa unar ncompress squashfs zoo
        already there: 7zip (7z, zip, iso, cab …), unrar (extract only), zip / unzip, tar with gzip / bzip2 / xz / zstd, rpm, cpio, bsdtar
        not possible:  creating .rar — needs the proprietary rar program, not packaged by openSUSE
    clipboard: wl-clip-persist 0.5.0 — the last copy stays available after the window it was copied from closes (on Wayland the clipboard otherwise empties with its owner)
        kept:    one item only, in memory — no history, nothing on disk, gone at logout; text, formatted text and pictures all survive
        how:     it takes over every copy as it happens and offers the same data types itself; started by sway/autostart.sh with --clipboard regular
        passwords: --all-mime-type-regex '^(?!x-kde-passwordManagerHint).+' — entries a password manager marks as sensitive are not taken over, so they vanish with their source
        build:   not packaged by openSUSE. sudo zypper install cargo (installed 2026-11-15); git clone --branch v0.5.0 https://github.com/Linus789/wl-clip-persist; cargo build --release --locked; install -m 755 target/release/wl-clip-persist ~/.local/bin/
        replaced bin/clip-persist, a wl-paste / wl-copy script from the same day that kept plain text only
        checked: text, formatted text, a picture (byte-identical), a sensitive entry and two copies in a row, in a headless sway
    sway: three window rules (sway/config, "Floating")
        archiver: every lxqt-archiver window floats; the main window (title ends in "File Archiver") is 960x600 in the centre, a quarter of the screen; prompts keep their own smaller size
            the archiver restores its own remembered size after sway places it, so ~/.config/lxqt/archiver.conf has WindowSize=@Size(960 600) as well
        Bitwarden: the Firefox extension's own windows (title starts "Extension: (Bitwarden Password Manager)") float in the centre — the two older Bitwarden rules only match the desktop program, which is not installed
        Content Manager: every steam_app_244210 window except the game ("Assetto Corsa") floats — the car / track picker opened tiled, and tiled windows are drawn underneath the floating full-screen main window
        checked: archiver rule in a headless sway (960x600 at 320,150). Bitwarden and Content Manager rules not yet seen against a real window
    Installed: bottom (btm) and ncdu from the openSUSE repos; bandwhich 0.23.1 is not packaged, so its GitHub release binary sits in ~/.local/bin
    waybar: cpu module click opens bottom, memory module click opens ncdu on the home folder (both in ghostty) — the rofi cpu / memory panels are gone (scripts/cpu-module.sh, scripts/mem-module.sh, rofi/dropdown-left.rasi and the hidden custom/cpusnap module removed)
    waybar: download speed is its own module (network#speed) — click opens bandwhich in ghostty through sudo (it needs root to watch traffic); the signal % and the network icon still open the wifi menu
    zsh: resizing the terminal no longer leaves copies of the prompt behind — POWERLEVEL9K_TERM_SHELL_INTEGRATION=true in zsh/p10k-colors.zsh marks the prompt (OSC 133), so Ghostty clears it on resize and zsh draws it once; checked in a headless sway by resizing a Ghostty window six times
    zsh: fastfetch is only shown while the window can hold it (105 columns x 22 rows) — a fresh terminal resized smaller is cleared instead of showing a re-wrapped logo, and the summary returns when it fits again (TRAPWINCH in .zshrc); after the first command it is left alone as scrollback; a terminal that opens too small skips it
    expose: window overview on $mod+Tab and on a click on the focused workspace icon in the top bar (bin/expose; the same again closes it) — live thumbnails of every window on every workspace
        program: "windows" (https://github.com/RadioNoiseE/windows), no openSUSE package — built from source into ~/.local/bin by expose/install.sh (sources in ~/.local/src/windows); bin/expose runs it and focuses the picked window through its foreign_toplevel_identifier in the sway tree
        keys:    arrow keys pick a window, Enter or space jumps to it and its workspace, Esc closes
        mouse:   expose/mouse.patch (applied by install.sh; upstream is keyboard-only and hides the pointer) — the window under the pointer is picked, a left click jumps to it, a click on the background closes
        history: first tried its predecessor exposway — dropped the same day: its daemon took a grim screenshot on every title change of the focused window (14 in 10 s with an animated terminal title), only showed windows that had been focused since it started, and its arrow keys also fired on key release
    waybar: the workspaces module is now three modules side by side (left icons, focused icon, right icons — workspaces.sh left / focused / right) so only the focused icon is clickable; the bar looks the same, pixel for pixel
    obs: OBS Studio 33.0.1 (packman) for screen recording, and as a way to get the screen into Discord — installed with v4l2loopback-kmp-default, v4l2loopback-utils (v4l2loopback-autoload loads the module at boot; it is openSUSE's own signed package, not a self-built module)
        camera:  /etc/modprobe.d/v4l2loopback.conf (copy of obs/v4l2loopback.conf) — one loopback device, /dev/video10, named "OBS Virtual Camera", exclusive_caps=1 so Chromium-based programs list it
        scene:   "Scene" with one source "Screen" (PipeWire screen capture of DP-2 through xdg-desktop-portal-wlr, which picks the output without a chooser); canvas and output 1920x1080 at 30 fps; recordings go to ~/Videos. Copies of the scene and profile are in obs/basic/ (the live ones are ~/.config/obs-studio/basic/)
        bin/screencam: starts OBS in the tray with the virtual camera running; run again to stop. In Discord: turn on Video and pick the camera "OBS Virtual Camera"
        checked: frames read back from /dev/video10 show the desktop at 1920x1080; the Discord side is not yet tried in a call
        Discord's own screen share was not debugged further: the portal itself works (a ScreenCast session returns a 1920x1080 stream) and Discord 1.0.169 contains the portal / PipeWire capture code
    audio: headphone EQ and PipeWire quality settings (pipewire/, linked into ~/.config/pipewire/) — DAC is a TI PCM2900C USB codec (16-bit, 32 / 44.1 / 48 kHz, class-compliant, no driver to install), headphones Sennheiser HD 599
        eq:      virtual output "HD 599 EQ" (hd599_eq) = PipeWire filter-chain with the AutoEq correction for oratory1990's HD 599 measurement (pipewire/hd599-oratory1990.txt: ten filters, -6.2 dB preamp) feeding the DAC; run by the filter-chain user service; it is the default output, the DAC sits behind it at 100%
        checked: response measured through the running EQ with -62 dBFS test tones at 11 frequencies — within 0.06 dB of the curve
        rates:   44.1 kHz allowed next to 48 kHz (pipewire/quality.conf) so 44.1 kHz music is not resampled; resample quality 10 for the cases that still convert (takes full effect at the next login)
        waybar:  the EQ's own stream is hidden from the volume dropup's program list
        to bypass: choose the DAC itself as output in pavucontrol
    sway: output is 10-bit (render_bit_depth 10 — the kernel reports an XR30 framebuffer); 1920x1080@180 with adaptive sync (48-180 Hz) was already set; screenshots and OBS capture still work
    sway: HDR prepared as an opt-in — login session "Sway (HDR)" (sway/sway-hdr.desktop, copied to /usr/local/share/wayland-sessions) starts sway with WLR_RENDERER=vulkan, which HDR needs and wlroots calls experimental; bin/hdr toggles HDR10 there (hdr / hdr on / hdr off / hdr status). The monitor reports HDR10 (PQ, BT.2020) with a peak around 300 nits. The Vulkan renderer starts on this machine in a headless test; HDR itself is not yet tried on the monitor
    file manager: Dolphin 26.08.3 — sudo zypper install dolphin kio-extras ffmpegthumbs kdegraphics-thumbnailers (thumbnails: images, video, PDF); xdg-mime default org.kde.dolphin.desktop inode/directory
        config:  dolphin/dolphinrc, copied to ~/.config/dolphinrc (a copy, not a link: Dolphin rewrites it with window state)
        colours: [UiSettings] ColorScheme=Mizu is required — outside Plasma, Dolphin otherwise forces its own scheme (Breeze light text, #232629, on the black view)
        look:    icon-only toolbar, 16 px toolbar / places icons, details view with whole-row highlight and expandable folders, full-width status bar (the default floating one was a white box), no folder-content previews
        kept:    address bar, toolbar, places panel, status bar; menu bar hidden as before (☰ menu)
        icons:   theme/install.sh also links inode-directory → the grey folder in Papirus-Mizu — Dolphin's file view asks for that name and got Papirus' blue folder
        checked: ~/Pictures in a headless sway — text, grey folders, thumbnails, status bar. Not checkable there (no keyboard, so the window never becomes active): the selected entry in the places panel showed light text on the light highlight — look at it with the window focused
    notifications: dunst replaced by SwayNotificationCenter (swaync 0.12.6) — swaync/config.json + style.css, ~/.config/swaync symlinked to it; ~/.config/dunst and dunst/dunstrc removed
        popups: same look as the dunst ones — black, square, 1px #4D4D5A frame (#BABAC6 for critical), JetBrainsMono 10, bold summary over the body, 32px icon on the left, low urgency in #9A9AA4; bottom-right, 10px from the edges, 6px apart; timeouts 4 / 6 / never
        panel:  swaync-client -t opens it flush under the top bar on the right (410px, like the rofi dropdowns): title + clear, do-not-disturb switch, notification history; the base for the quick access menu
        sway/autostart.sh starts swaync instead of dunst
    waybar: do-not-disturb module uses swaync (swaync-client -d / -D) instead of dunstctl; wifi and bluetooth menus send their messages with notify-send instead of dunstify
    waybar: the bluetooth module became quick access (custom/quick, scripts/quick-module.sh) — click opens the swaync panel; shows "● REC" and the pomodoro time left in front of its icon while they run (signal 12)
        panel tiles (swaync/config.json, buttons-grid): bluetooth · screenshot · record · pomodoro / KDE Connect · notes · calculator; toggles turn light grey while on
        bluetooth:  bluetui in Ghostty; until bluetui is installed it falls back to the old rofi menu (bt-module.sh --menu)
        screenshot: scripts/screenshot.sh — slurp region (a click takes the whole screen), saved to ~/Pictures/Screenshots and copied to the clipboard
        record:     scripts/obs-record.py — starts / stops recording in OBS through its websocket server (enabled in OBS's plugin_config, password auth, port 4455); starts OBS in the tray when it is not running and quits it again afterwards; saves to ~/Videos
        pomodoro:   scripts/pomodoro.sh — 25 min focus / 5 min break, 15 min every 4th; a notification at each change; stopped by a second click
        notes:      scripts/notes.sh — rofi dropdown of ~/Documents/notes (newest first); typing a name that is not listed starts a new note; opens nvim in a floating Ghostty (app_id quick.notepad)
        calculator: GMNB 0.3.0 (github.com/Go08er/GlazeMyNumbersBaby, Windows Calculator ported to Rust / GTK 4) — GMNB.flatpak from the release, checked against its SHA256SUMS, flatpak install --user
        tile glyphs are scaled with transform: swaync ignores font-size on them
        checked: pomodoro start / bar countdown / stop; a 4 s recording started and stopped from the script (OBS launched and quit); panel screenshots
    sway: notes (app_id quick.notepad) and the GMNB calculator float — 760x520 / 420x640 in the centre the first time; sway/float-memory.py (started by autostart.sh) saves each one's position and size when it closes and puts the next one back there (~/.local/state/float-memory.json). Move: $mod + left drag, resize: $mod + right drag
        checked: notepad window moved and resized, closed, reopened at the same place and size
    system: installed bluetui (bluetooth tile of the quick access panel); removed dunst, dunst-bash-completion, dunst-zsh-completion and mako (swaync handles notifications)
    waybar: quick access icon back to the old bluetooth module's SF Symbols glyph (U+10070A)
    swaync: the panel opens over the right end of the top bar, like the rofi launcher over its left end — overlay layer, no exclusive zone; the "quick access" heading is a 27px row on the bar's text line, and the panel lost its frame, so bar and panel are one black piece with no line between them. While it is open the clock / weather / quick icon are covered: Esc or a click outside closes it
    swaync: panel is a separate card again — top layer below the bar, 10px from the bar and the right edge (the popups' gap), 1px #4D4D5A frame all round; replaces the over-the-bar version
    waybar: do-not-disturb module removed from the bottom bar (custom/dnd, scripts/dnd-module.sh deleted) — the switch in the quick access panel does the same

## Repo Layout:
    pipewire/    hd599-eq.conf + hd599-oratory1990.txt (headphone EQ), quality.conf, client-quality.conf (sample rates, resampler); ln -s into ~/.config/pipewire/*.conf.d
    sway/        sway-hdr.desktop (HDR login session), config, autostart.sh, lock.sh, waybar.sh (starts / restarts the bars), inactive-opacity.sh (see-through unfocused windows)
    bin/         ws-color (workspace icon colours), ws-swap (swap two workspace icons), expose (window overview), screencam (screen as a webcam through OBS), hdr (HDR toggle); ln -s into ~/.local/bin
    applications/ nvim-ghostty.desktop; ln -s into ~/.local/share/applications
    environment.d/ editor.conf, qt.conf (Qt programs use qt5ct / qt6ct); ln -s into ~/.config/environment.d
    theme/       gtk.css (GTK 3 + shared rules), gtk4.css (GTK 4 / libadwaita), settings.ini, Mizu.colors (KDE colour scheme), install.sh (fetches adw-gtk3, builds the icon theme, links everything, sets gsettings)
    kvantum/     Mizu/ (Qt theme: Mizu.kvconfig, Mizu.svg), build-svg.py (draws Mizu.svg), kvantum.kvconfig; linked as ~/.config/Kvantum
    qt5ct/ qt6ct/ qt5ct.conf, qt6ct.conf (style kvantum, icons, fonts)
    waybar/      config.jsonc, style.css, scripts/ (rofi menus go through _rofi_engine.sh)
    rofi/        config.rasi (launcher), dropdown.rasi / dropup.rasi / dropup-left.rasi / dropup-right.rasi (top-right / bottom-centre / bottom-left / bottom-right bar menus), music.rasi (cover-art dropup), colors.rasi
    ghostty/     config, colors, fonts
    dolphin/     dolphinrc (file manager look and colour scheme); copied into ~/.config once
    vlc/         vlc-qt-interface.conf (toolbar layout with theme sliders), vlcrc; copied into ~/.config/vlc once
    firefox/     user.js (preferences re-applied at every start); ln -s into the Firefox profile directory
    sddm/        theme/ (Main.qml, metadata.desktop, theme.conf), install.sh, wallpaper.sh (rotating photo)
    hyprlock/    hyprlock.conf (lock screen); ln -s into ~/.config/hypr
    systemd/     login-wallpaper.service + .timer; ln -s into ~/.config/systemd/user
    nvim/        init.lua, lua/options.lua, lua/keymaps.lua, lua/plugins/{ui,editor,treesitter,lsp}.lua, lazy-lock.json (pinned plugin versions)
    zsh/         .zshrc, p10k-colors.zsh (prompt style and colours), install-plugins.sh (fetches the zsh plugins)
    fastfetch/   config.jsonc
    swaync/      config.json, style.css (notification popups + the panel); ln -s ~/.dotfiles/swaync ~/.config/swaync
    obs/         v4l2loopback.conf (virtual camera module options, copied to /etc/modprobe.d), basic/ (scene and profile, copied from ~/.config/obs-studio)
    expose/      install.sh (builds the window overview from source), mouse.patch (adds hover and click)
    swaylock/    config (lock screen)
    p10k/        powerlevel10k checkout
    wallpapers/  wallpaper.jpg
Palette: background #070708, foreground #e3e2e9, accent #BABAC6, dim #7C7C84, border #4D4D5A. Font: JetBrainsMono Nerd Font (bar, terminal, code); SF Pro Text in GTK and Qt programs.
Shades used by the GTK / Qt theme: inputs #0B0B0D, buttons #131315, hover #1B1B20, pressed #2A2A32, dividers #2E2E37.

## Keybinds (sway):
    $mod = Super
    ctrl+space            rofi launcher
    $mod+space / Return   ghostty
    $mod+q                kill window
    $mod+Tab              window overview
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
    - ~/.p10k.zsh lives outside the repo (its colours are overridden by zsh/p10k-colors.zsh)
    - p10k is a gitlink without .gitmodules — make it a real submodule or install it another way
    - Waybar temperature uses a fixed hwmon4 path that can shift between boots
    - Clean out leftover Polybar/Alacritty comments in the scripts
    - Bottom-bar uptime module shows nothing: this uptime has no -p option
    - Quick access: a greyscale theme for the GMNB calculator (out of the box it has a blue accent)
    - Quick access: screenshot and notes tiles not yet tried by hand (both need a mouse / keyboard)
    - wallpaper.jpg is 30MB — compress it or keep it out of git
    - Cursor theme: sway/config asks for Quintom_Ink but it is not installed anywhere, so the default cursor shows — install it into ~/.local/share/icons, then gsettings set org.gnome.desktop.interface cursor-theme Quintom_Ink
    - Konsole's terminal area still uses its own Breeze colour scheme (only matters if Konsole gets used instead of Ghostty)
    - ProtonUp-Qt (flatpak, Qt) is not themed: needs the org.kde.KStyle.Kvantum flatpak runtime plus access to ~/.config/Kvantum
- System:
    - Firewall rules still unread (needs the password):  sudo firewall-cmd --list-all  — expect only dhcpv6-client (and maybe ssh) under services
        mpd listens on every interface (port 6600) and Steam Remote Play on 27036; the public zone should be blocking both from the network
    - Firefox: two translators installed (Simple Translate and TWP) — keep one; 15 unused black themes next to the active one
    - Window rules not yet seen against a real window: Bitwarden extension windows (title pattern), Content Manager car / track picker
    - cargo + rust (1.4 GB) are only needed to rebuild wl-clip-persist:  sudo zypper remove --clean-deps cargo
    - Bluetooth: pair and connect a real device through the bar menu (only tested against a stub so far)
    - BIOS: PBO or 105W cTDP — the only BIOS item left; cannot be checked from Linux without root
        Gigabyte B850M: Del at boot → Tweaker → Precision Boost Overdrive → "AMD ECO Mode / TDP to 105W" (or PBO: Enabled); expect higher temperatures, watch them in btop
    - Secure Boot (optional) — currently disabled and the firmware is in Setup Mode (no keys enrolled)
        ready on the Linux side: boots through the signed shim (Boot0002 opensuse-secureboot), SECURE_BOOT="yes" in /etc/sysconfig/bootloader, no out-of-tree kernel modules
        BIOS: Boot → CSM Support: Disabled → Secure Boot → Secure Boot Mode: Custom → Restore Factory Keys → Mode back to Standard → Secure Boot: Enabled
        check:  mokutil --sb-state → "SecureBoot enabled"
        if it does not boot: same menu, Secure Boot: Disabled — nothing on disk changes
    - Ethernet enp10s0 still shows no link — cable or router
