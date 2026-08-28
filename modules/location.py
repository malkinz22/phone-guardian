"""
location.py
Fetches current GPS location using termux-location (from termux-api),
and formats it into a human-readable Google Maps link.
"""

import json
import subprocess


def get_location():
    """
    Returns a dict with latitude, longitude, accuracy, provider - or None on failure.
    Requires: pkg install termux-api  +  Termux:API app installed from F-Droid/Play Store.
    """
    try:
        result = subprocess.run(
            ["termux-location", "-p", "gps", "-r", "once"],
            capture_output=True,
            text=True,
            timeout=30,
        )
        if result.returncode != 0 or not result.stdout.strip():
            return None
        return json.loads(result.stdout)
    except (subprocess.TimeoutExpired, json.JSONDecodeError, FileNotFoundError) as e:
        print(f"[location] Could not get location: {e}")
        return None


def location_to_message(loc):
    if loc is None:
        return "Could not retrieve location. GPS may be off or permission denied."

    lat = loc.get("latitude")
    lon = loc.get("longitude")
    accuracy = loc.get("accuracy", "unknown")
    maps_link = f"https://maps.google.com/?q={lat},{lon}"

    return (
        "Phone Guardian - Location Report\n"
        f"Latitude: {lat}\n"
        f"Longitude: {lon}\n"
        f"Accuracy: {accuracy} m\n"
        f"Map: {maps_link}"
    )
