# Razer Cobra Linux Companion Tools

Razer Cobra Linux Companion Tools is an unofficial Linux utility suite for
monitoring Razer Cobra DPI changes and controlling mouse lighting brightness
through OpenRazer, Polychromatic, and KDE Plasma's D-Bus OSD service. It is
designed for KDE Plasma users and is not a general replacement for Razer
Synapse or a promise of support for every Razer device.

This project is independent and is not affiliated with, endorsed by, or
sponsored by Razer, OpenRazer, Polychromatic, KDE, or their respective owners.

## Scope

The project provides two small user-session tools:

- A DPI monitor that polls an OpenRazer-supported Razer Cobra and shows a KDE
  Plasma OSD notification when the DPI changes.
- A brightness command that cycles the mouse lighting through 100%, 66%, 33%,
  1%, and off.

It currently targets Linux systems running KDE Plasma 6, a systemd user
session, and an OpenRazer-supported Razer Cobra. GNOME, other desktop
environments, Windows, macOS, and unsupported Razer devices are out of scope.

## Requirements

- A Razer Cobra mouse supported by the installed OpenRazer version.
- OpenRazer daemon and Python bindings.
- Polychromatic, including `polychromatic-cli`.
- Python 3.
- KDE Plasma 6 with `qdbus6` and the `org.kde.osdService` D-Bus service.
- A systemd user session for the optional DPI monitor service.
- USB device permissions configured as required by the distribution. Some
  distributions use the `plugdev` group; others use udev rules instead.

The package names and OpenRazer installation process vary by distribution.
On Arch Linux or CachyOS, one possible installation is:

```bash
paru -S openrazer-daemon python-openrazer polychromatic
```

After changing device groups or udev rules, log out and back in if the
distribution requires it. Start and verify the OpenRazer daemon before using
these tools. No root privileges are required by the scripts themselves.

## Installation

Clone the repository wherever you prefer:

```bash
git clone https://github.com/buraakkcayir/razer-cobra-linux.git
cd razer-cobra-linux
chmod +x razer-brightness.sh razer-dpi-monitor.py
```

Install the DPI monitor script into a stable per-user location used by the
provided systemd unit:

```bash
install -Dm755 razer-dpi-monitor.py \
  "$HOME/.local/lib/razer-cobra-linux/razer-dpi-monitor.py"
install -Dm755 razer-brightness.sh \
  "$HOME/.local/lib/razer-cobra-linux/razer-brightness.sh"
install -Dm755 razer-brightness.sh \
  "$HOME/.local/bin/razer-brightness.sh"
install -Dm644 razer-restore.desktop \
  "$HOME/.config/autostart/razer-restore.desktop"
install -Dm644 razer-brightness-up.desktop \
  "$HOME/.local/share/applications/razer-brightness-up.desktop"
install -Dm644 razer-brightness-down.desktop \
  "$HOME/.local/share/applications/razer-brightness-down.desktop"
install -Dm644 net.local.razer-brightness.sh.desktop \
  "$HOME/.local/share/applications/net.local.razer-brightness.sh.desktop"
install -Dm644 net.local.razer-brightness.sh-2.desktop \
  "$HOME/.local/share/applications/net.local.razer-brightness.sh-2.desktop"
install -Dm644 razer-cobra.svg \
  "$HOME/.local/share/icons/hicolor/scalable/devices/razer-cobra.svg"
install -Dm644 razer-dpi-monitor.service \
  "$HOME/.config/systemd/user/razer-dpi-monitor.service"
systemctl --user daemon-reload
systemctl --user enable --now openrazer-daemon.service
systemctl --user enable --now razer-dpi-monitor.service
```

The DPI monitor is intentionally installed as a user service. It does not
run as root and does not modify system-wide files. The included KDE autostart
entry runs the tested `$HOME/.local/bin/razer-brightness.sh restore` command
after login. The command waits 10 seconds before each of three attempts, so
OpenRazer and the mouse can finish initializing before brightness is restored.

## Usage

Run the brightness command from the repository directory:

```bash
./razer-brightness.sh up
./razer-brightness.sh down
./razer-brightness.sh restore
```

`inc` is an alias for `up` and `dec` is an alias for `down`. Configure KDE
global shortcuts under **System Settings > Keyboard > Shortcuts > Custom
Shortcuts**. Assign `Razer Cobra Brightness Up` to
`Shift+Volume Up` and `Razer Cobra Brightness Down` to
`Shift+Volume Down`.
The installed desktop entries call `$HOME/.local/bin/razer-brightness.sh`;
they do not configure or override shortcuts automatically.

On this keyboard, `Fn+Up` and `Fn+Down` are reported as volume controls, so
KDE displays them as `Volume Up` and `Volume Down`. Hold `Shift` while
pressing those keys when recording the shortcuts.
If KDE's built-in `Shift+Volume Up` and `Shift+Volume Down` actions are still
assigned to small volume changes, remove those assignments first to avoid a
shortcut conflict.

DPI changes are intentionally not mapped to keyboard shortcuts. The Razer Cobra
mouse's physical DPI button remains the DPI control.

The equivalent commands, if you prefer to create custom shortcuts manually,
are:

```bash
razer-brightness.sh up
razer-brightness.sh down
```

To restore 100% brightness manually:

```bash
./razer-brightness.sh restore
```

The installation commands above enable the KDE autostart entry automatically.
It runs once per user login, and the `restore` action provides a 10-second
delay before each attempt. To disable automatic restoration, remove the
autostart entry:

```bash
rm -- "$HOME/.config/autostart/razer-restore.desktop"
```

## Configuration

| Variable | Default | Description |
| --- | --- | --- |
| `XDG_CACHE_HOME` | `~/.cache` | Parent directory for the brightness state file |
| State file | `$XDG_CACHE_HOME/razer_brightness` | Last brightness level used by the script |
| Brightness levels | `100, 66, 33, 1, 0` | Ordered levels used by `up` and `down` |
| `RAZER_DPI_POLL_INTERVAL` | `0.25` seconds | DPI monitor polling interval; must be positive |

The state file contains only the numeric brightness level. Keep the cache
directory private if your system has unusual shared-home permissions.

The OSD icon name is `razer-cobra`. To use the included SVG, install it into
your local KDE icon theme according to KDE's icon-theme conventions, or use
the default mouse icon by changing the icon name in both scripts. The included
monochrome outline SVG was drawn specifically for this project and contains no
third-party artwork or copied brand logo.

## Troubleshooting

- Check that `openrazer-daemon` is running and that the mouse is supported.
- If multiple mice are connected, the monitor selects only a device whose
  OpenRazer name contains `Cobra`.
- Check that `polychromatic-cli` is available with `command -v
  polychromatic-cli`.
- Check that `qdbus6` is available and that KDE Plasma is running.
- Inspect the user service with
  `systemctl --user status razer-dpi-monitor.service` and
  `journalctl --user -u razer-dpi-monitor.service`.
- If the mouse is not accessible, review the distribution's OpenRazer udev
  rules and device-group instructions.
- If the OSD text appears without the custom icon, install `razer-cobra.svg`
  into a local icon theme or change the icon name as described above.

The monitor reports dependency, device, reconnection, and OSD failures to
stderr or the systemd journal. To change its polling interval, create a user
service drop-in with `systemctl --user edit razer-dpi-monitor.service` and add
`[Service]` followed by, for example,
`Environment=RAZER_DPI_POLL_INTERVAL=0.5`. Brightness command failures return
a non-zero exit status.

## Uninstall

Disable and remove the user service, then remove the per-user installed copy:

```bash
systemctl --user disable --now razer-dpi-monitor.service
SERVICE_FILE="$HOME/.config/systemd/user/razer-dpi-monitor.service"
AUTOSTART_FILE="$HOME/.config/autostart/razer-restore.desktop"
INSTALL_DIR="$HOME/.local/lib/razer-cobra-linux"
BRIGHTNESS_COMMAND="$HOME/.local/bin/razer-brightness.sh"
UP_DESKTOP="$HOME/.local/share/applications/razer-brightness-up.desktop"
DOWN_DESKTOP="$HOME/.local/share/applications/razer-brightness-down.desktop"
LEGACY_UP_DESKTOP="$HOME/.local/share/applications/net.local.razer-brightness.sh.desktop"
LEGACY_DOWN_DESKTOP="$HOME/.local/share/applications/net.local.razer-brightness.sh-2.desktop"
if [ -f "$SERVICE_FILE" ]; then
  rm -- "$SERVICE_FILE"
fi
if [ -f "$AUTOSTART_FILE" ]; then
  rm -- "$AUTOSTART_FILE"
fi
for file in "$BRIGHTNESS_COMMAND" "$UP_DESKTOP" "$DOWN_DESKTOP" \
  "$LEGACY_UP_DESKTOP" "$LEGACY_DOWN_DESKTOP"; do
  if [ -f "$file" ]; then
    rm -- "$file"
  fi
done
if [ -d "$INSTALL_DIR" ] && [ "$INSTALL_DIR" != "$HOME" ] && [ "$INSTALL_DIR" != "/" ]; then
  find "$INSTALL_DIR" -xdev -mindepth 1 -delete
  rmdir -- "$INSTALL_DIR"
fi
systemctl --user daemon-reload
```

Remove the repository clone and, if desired, the state file:

```bash
STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/razer_brightness"
if [ -f "$STATE_FILE" ]; then
  rm -- "$STATE_FILE"
fi
```

Only remove the state file if `XDG_CACHE_HOME` is set to the same value used
when the tool was run. The guarded commands above avoid recursive deletion and
do not follow directory mount points.

## License and third-party notes

This project is released under the MIT License; see [LICENSE](LICENSE).
OpenRazer, Polychromatic, KDE Plasma, Python, and their dependencies retain
their own licenses and trademarks. Review the installed package licenses
before redistributing a bundled build.
