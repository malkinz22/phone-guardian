"""
alarm.py
Makes the phone hard to ignore: max volume, loud tone, vibration,
and a persistent notification. Useful if the phone is just lost nearby
(under a couch cushion) rather than stolen.
"""

import subprocess


def sound_alarm(duration_seconds=15):
    try:
        # Max media volume
        subprocess.run(["termux-volume", "music", "15"], timeout=5)
        # Vibrate in a pattern for the given duration (ms)
        subprocess.run(
            ["termux-vibrate", "-d", str(duration_seconds * 1000), "-f"],
            timeout=5,
        )
        # Persistent notification so it's visible even if muted somehow
        subprocess.run(
            [
                "termux-notification",
                "--title", "Phone Guardian ALERT",
                "--content", "Panic trigger activated",
                "--priority", "max",
                "--vibrate", "500,200,500",
            ],
            timeout=5,
        )
        return True
    except (subprocess.TimeoutExpired, FileNotFoundError) as e:
        print(f"[alarm] Could not sound alarm: {e}")
        return False
