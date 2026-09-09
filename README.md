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
install -Dm644 razer-dpi-monitor.service \
  "$HOME/.config/systemd/user/razer-dpi-monitor.service"
systemctl --user daemon-reload
systemctl --user enable --now razer-dpi-monitor.service
```

The service is intentionally installed as a user service. It does not run as
root and does not modify system-wide files.

## Usage

Run the brightness command from the repository directory:

```bash
./razer-brightness.sh up
./razer-brightness.sh down
./razer-brightness.sh restore
```

`inc` is an alias for `up` and `dec` is an alias for `down`. Configure KDE
custom shortcuts with the absolute path to your clone, replacing the example
path below:

```text
/path/to/razer-cobra-linux/razer-brightness.sh up
/path/to/razer-cobra-linux/razer-brightness.sh down
```

To restore 100% brightness after login, run the following command from KDE
autostart or another user-session mechanism:

```text
/path/to/razer-cobra-linux/razer-brightness.sh restore
```

## Configuration

| Variable | Default | Description |
| --- | --- | --- |
| `XDG_CACHE_HOME` | `~/.cache` | Parent directory for the brightness state file |
| State file | `$XDG_CACHE_HOME/razer_brightness` | Last brightness level used by the script |
| Brightness levels | `100, 66, 33, 1, 0` | Ordered levels used by `up` and `down` |

The state file contains only the numeric brightness level. Keep the cache
directory private if your system has unusual shared-home permissions.

The OSD icon name is `razer-cobra`. To use the included SVG, install it into
your local KDE icon theme according to KDE's icon-theme conventions, or use
the default mouse icon by changing the icon name in both scripts. The SVG is
an original project asset; replace it with an appropriately licensed asset if
you redistribute a modified version.

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
stderr or the systemd journal. Brightness command failures return a non-zero
exit status.

## Uninstall

Disable and remove the user service, then remove the per-user installed copy:

```bash
systemctl --user disable --now razer-dpi-monitor.service
rm "$HOME/.config/systemd/user/razer-dpi-monitor.service"
rm -rf "$HOME/.local/lib/razer-cobra-linux"
systemctl --user daemon-reload
```

Remove the repository clone and, if desired, the state file:

```bash
rm "$XDG_CACHE_HOME/razer_brightness"
```

Only remove the state file if `XDG_CACHE_HOME` is set to the same value used
when the tool was run.

## License and third-party notes

This project is released under the MIT License; see [LICENSE](LICENSE).
OpenRazer, Polychromatic, KDE Plasma, Python, and their dependencies retain
their own licenses and trademarks. Review the installed package licenses
before redistributing a bundled build.
