# Razer Cobra Linux Companion Tools

A lightweight hardware utility suite for the **Razer Cobra** gaming mouse on **Linux (specifically optimized for KDE Plasma 6)**.

This suite fills the gap left by Razer Synapse on Linux by providing:
1. **Dynamic DPI OSD Monitor:** Displays native On-Screen Display notifications whenever you press the physical DPI switch button.
2. **Stepped RGB Brightness Controller:** Smoothly cycles LED brightness across 5 distinct levels (100% -> 66% -> 33% -> 1% -> Off) with native OSD feedback.

---

## ✨ Features

- **Native Plasma 6 OSD Integration:** Uses KDE's D-Bus OSD service (`org.kde.osdService`) with the official `input-mouse` icon.
- **Hardware-Level Polling:** Sub-second polling (250ms) using `openrazer` bindings with zero noticeable CPU usage.
- **Graceful Reconnection:** Automatically recovers when the mouse enters USB sleep or is unplugged/replugged.
- **Boot Brightness Restoration:** Includes a resilient `restore` routine that handles the startup latency of OpenRazer daemon.

---

## 📦 Requirements

Install OpenRazer and Polychromatic:

On Arch Linux / CachyOS:
```bash
paru -S openrazer-daemon python-openrazer polychromatic
```

*(Make sure your user is in the `plugdev` group: `sudo usermod -aG plugdev $USER`).*

---

## 🚀 Setup & Usage

### 1. Enable DPI Monitor Daemon (Auto-Start)
To monitor DPI changes in the background and show notifications:

```bash
mkdir -p ~/.config/systemd/user
cp razer-dpi-monitor.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now razer-dpi-monitor.service
```

### 2. Configure Brightness Shortcuts (KDE Plasma)
Go to **System Settings** -> **Shortcuts** -> **Add New** -> **Command**:

| Action | Shortcut (Example) | Command |
| :--- | :--- | :--- |
| **Increase Brightness** | `Custom Shortcut` | `/path/to/razer-cobra-linux/razer-brightness.sh up` |
| **Decrease Brightness** | `Custom Shortcut` | `/path/to/razer-cobra-linux/razer-brightness.sh down` |

### 3. (Optional) Enforce 100% Brightness on Boot
Add this command to your login scripts / autostart if you want the mouse to guarantee full brightness on startup:
```bash
/path/to/razer-cobra-linux/razer-brightness.sh restore
```

---

## 📜 License
MIT License
