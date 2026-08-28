"""
sim_watch.py
Detects if the SIM card has been swapped by comparing the current
telephony device info against a saved fingerprint. Useful because thieves
often swap the SIM first thing - this can trigger an alert the moment
that happens (run this via a scheduled job, see README).
"""

import json
import os
import subprocess

STATE_PATH = os.path.join(os.path.dirname(__file__), "..", "sim_state.json")


def get_sim_info():
    """Returns telephony device info dict, or None on failure."""
    try:
        result = subprocess.run(
            ["termux-telephony-deviceinfo"],
            capture_output=True,
            text=True,
            timeout=15,
        )
        if result.returncode != 0 or not result.stdout.strip():
            return None
        return json.loads(result.stdout)
    except (subprocess.TimeoutExpired, json.JSONDecodeError, FileNotFoundError) as e:
        print(f"[sim_watch] Could not get SIM info: {e}")
        return None


def _fingerprint(info):
    # sim_serial_number isn't always populated depending on Android version/carrier,
    # so we fall back to a combination of fields that are reliably present.
    return "|".join([
        str(info.get("sim_serial_number", "")),
        str(info.get("sim_operator_name", "")),
        str(info.get("sim_country_iso", "")),
        str(info.get("network_operator_name", "")),
    ])


def save_current_state():
    info = get_sim_info()
    if info is None:
        return False
    with open(STATE_PATH, "w") as f:
        json.dump({"fingerprint": _fingerprint(info), "raw": info}, f, indent=2)
    return True


def has_sim_changed():
    """Returns True if SIM appears to have changed since last save_current_state() call."""
    if not os.path.exists(STATE_PATH):
        # No baseline saved yet - treat as "no change" and save one now.
        save_current_state()
        return False

    with open(STATE_PATH, "r") as f:
        saved = json.load(f)

    current_info = get_sim_info()
    if current_info is None:
        return False  # can't tell right now, don't false-alarm

    return _fingerprint(current_info) != saved.get("fingerprint")
