#!/usr/bin/env python3
import time
import subprocess
import sys

try:
    from openrazer.client import DeviceManager
except ImportError:
    print("Error: OpenRazer Python library not found. Please install python-openrazer.", file=sys.stderr)
    sys.exit(1)

def show_osd(text):
    result = subprocess.run([
        "qdbus6", "org.kde.plasmashell", "/org/kde/osdService",
        "org.kde.osdService.showText", "razer-cobra", text
    ], capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Warning: KDE OSD notification failed: {result.stderr.strip()}", file=sys.stderr)

def main():
    last_dpi = None
    mouse = None

    while True:
        try:
            # Only select the intended Razer Cobra device when several mice exist.
            if mouse is None:
                devman = DeviceManager()
                for dev in devman.devices:
                    if dev.type == "mouse" and "cobra" in dev.name.lower():
                        mouse = dev
                        # Read baseline DPI on startup to prevent unwanted popup
                        last_dpi = mouse.dpi[0]
                        break
                
                if mouse is None:
                    print("Waiting for an OpenRazer-supported Razer Cobra mouse.", file=sys.stderr)
                    time.sleep(2)
                    continue

            # Read current hardware DPI
            cur_dpi = mouse.dpi[0]

            # Display OSD feedback on DPI change
            if last_dpi is not None and cur_dpi != last_dpi:
                show_osd(f"Razer Cobra: {cur_dpi} DPI")
                last_dpi = cur_dpi

        except Exception as error:
            print(f"Warning: OpenRazer device unavailable; retrying: {error}", file=sys.stderr)
            mouse = None
            time.sleep(2)

        # Low-overhead polling interval (250ms is smooth and CPU-friendly)
        time.sleep(0.25)

if __name__ == "__main__":
    main()
