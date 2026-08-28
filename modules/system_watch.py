"""
system_watch.py
Watches for system-level anomalies you'd want to know about:
- new/unexpected running processes
- app crash indicators via logcat (if accessible)
- storage/battery anomalies that might indicate something misbehaving

This is diagnostic visibility, not a security scanner - it surfaces
changes for you to judge, it doesn't claim to detect "threats."
"""

import json
import os
import subprocess

STATE_PATH = os.path.join(os.path.dirname(__file__), "..", "syswatch_state.json")


def get_running_processes():
    """List currently running process names (best-effort, no root needed for own processes)."""
    try:
        result = subprocess.run(["ps", "-A"], capture_output=True, text=True, timeout=10)
        if result.returncode != 0:
            return []
        lines = result.stdout.strip().split("\n")[1:]  # skip header
        names = set()
        for line in lines:
            parts = line.split()
            if parts:
                names.add(parts[-1])
        return sorted(names)
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return []


def load_known_processes():
    if not os.path.exists(STATE_PATH):
        return set()
    with open(STATE_PATH, "r") as f:
        data = json.load(f)
    return set(data.get("known_processes", []))


def save_known_processes(proc_set):
    with open(STATE_PATH, "w") as f:
        json.dump({"known_processes": sorted(proc_set)}, f, indent=2)


def check_for_new_processes():
    """Returns list of process names not seen in the saved baseline. First run sets baseline."""
    current = set(get_running_processes())
    known = load_known_processes()

    if not known:
        save_known_processes(current)
        return []

    new_procs = current - known
    if new_procs:
        save_known_processes(current | known)

    return sorted(new_procs)


def get_recent_crashes(lines=200):
    """
    Best-effort recent crash/error scan via logcat, if accessible.
    On many devices Termux can't read other apps' logs without special
    permission (Android restricts this since API 29) - this degrades
    gracefully if unavailable.
    """
    try:
        result = subprocess.run(
            ["logcat", "-d", "-v", "brief", "*:E"],
            capture_output=True, text=True, timeout=15
        )
        if result.returncode != 0 or not result.stdout.strip():
            return []
        entries = result.stdout.strip().split("\n")[-lines:]
        return entries
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return []


def get_battery_status():
    try:
        result = subprocess.run(
            ["termux-battery-status"], capture_output=True, text=True, timeout=10
        )
        if result.returncode != 0:
            return None
        return json.loads(result.stdout)
    except (subprocess.TimeoutExpired, json.JSONDecodeError, FileNotFoundError):
        return None
