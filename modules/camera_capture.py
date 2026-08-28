"""
camera_capture.py
Takes a photo with the front camera (silent - no shutter UI in Termux)
using termux-camera-photo. Useful for capturing whoever is holding
the phone when a panic trigger fires.
"""

import os
import subprocess
import tempfile
import time


def capture_photo(camera_id="0"):
    """
    camera_id: '0' is usually the back camera, '1' the front camera on most devices.
    Run `termux-camera-info` to check which id maps to which lens on your device.
    Returns the path to the saved jpg, or None on failure.
    """
    photo_path = os.path.join(tempfile.gettempdir(), f"capture_{int(time.time())}.jpg")

    try:
        result = subprocess.run(
            ["termux-camera-photo", "-c", camera_id, photo_path],
            capture_output=True,
            text=True,
            timeout=20,
        )
        if result.returncode == 0 and os.path.exists(photo_path):
            return photo_path
        return None
    except (subprocess.TimeoutExpired, FileNotFoundError) as e:
        print(f"[camera_capture] Could not capture photo: {e}")
        return None
