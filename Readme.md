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

## TODO:
    - output DP-2 adaptive_sync on in sway config
    - 32-bit graphics libs: libvulkan_radeon-32bit Mesa-libGL-32bit Mesa-libEGL-32bit
    - xdg-user-dirs + home directory structure
    - Clone dotfiles, translate i3 config to sway
    - Set the hostname — still localhost
    - Packman repo and codecs
    - Steam, gamescope, mangohud
    - BIOS: Above 4G Decoding + Resizable BAR, SVM Mode, PBO or 105W cTDP
    - Optionally re-enable Secure Boot
    - Remove leftover /boot/efi/EFI/Microsoft and regenerate grub.cfg
    - Confirm native resolution — currently 1080p180, panel also offers 1440p75
    - Ethernet enp10s0 still shows no link — cable or router
    - rpm -V vulkan-tools — reported an error on install
    - monitor gsync enable
    - 
