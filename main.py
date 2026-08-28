#!/usr/bin/env python3
"""
Phone Guardian - main.py
A Termux-based anti-theft toolkit for your own Android phone.

Commands:
    python main.py report        -> send location report to Telegram now
    python main.py panic         -> sound alarm + take photo + send location
    python main.py check-sim     -> check if SIM has changed, alert if so
    python main.py baseline-sim  -> save current SIM as the "trusted" baseline
    python main.py watch         -> poll for a keyword SMS to trigger 'panic' remotely

See README.md for setup instructions.
"""

import sys

from modules import alarm, camera_capture, location, notifier, sim_watch


def cmd_report():
    loc = location.get_location()
    notifier.send_message(location.location_to_message(loc))
    print("Location report sent.")


def cmd_panic():
    print("PANIC triggered.")
    alarm.sound_alarm()

    loc = location.get_location()
    notifier.send_message("PANIC TRIGGERED\n\n" + location.location_to_message(loc))

    photo_path = camera_capture.capture_photo(camera_id="1")  # 1 = front camera, usually
    if photo_path:
        notifier.send_photo(photo_path, caption="Captured after panic trigger")
    else:
        notifier.send_message("Could not capture photo (camera busy or unavailable).")


def cmd_check_sim():
    if sim_watch.has_sim_changed():
        notifier.send_message(
            "WARNING: SIM card has changed on your device! "
            "If this wasn't you, your phone may be stolen."
        )
        print("SIM change detected - alert sent.")
    else:
        print("SIM unchanged.")


def cmd_baseline_sim():
    if sim_watch.save_current_state():
        print("Current SIM saved as trusted baseline.")
    else:
        print("Could not read SIM info to save baseline.")


def cmd_watch(keyword="GUARDIAN PANIC"):
    """
    Polls incoming SMS for a trigger keyword sent from your own other number.
    This lets you trigger 'panic' remotely even with no data/app access -
    just send an SMS with the keyword to the stolen phone.
    Requires termux-sms-list (part of termux-api) and read SMS permission.
    """
    import json
    import subprocess
    import time

    print(f"Watching for SMS containing '{keyword}'... (Ctrl+C to stop)")
    seen_ids = set()

    while True:
        try:
            result = subprocess.run(
                ["termux-sms-list", "-l", "5"], capture_output=True, text=True, timeout=15
            )
            messages = json.loads(result.stdout) if result.stdout.strip() else []

            for msg in messages:
                msg_id = msg.get("_id")
                body = msg.get("body", "")
                if msg_id not in seen_ids:
                    seen_ids.add(msg_id)
                    if keyword.lower() in body.lower():
                        print("Trigger SMS received - running panic sequence.")
                        cmd_panic()

            time.sleep(30)
        except KeyboardInterrupt:
            print("\nStopped watching.")
            break
        except Exception as e:
            print(f"[watch] error: {e}")
            time.sleep(30)


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return

    command = sys.argv[1]
    commands = {
        "report": cmd_report,
        "panic": cmd_panic,
        "check-sim": cmd_check_sim,
        "baseline-sim": cmd_baseline_sim,
        "watch": cmd_watch,
    }

    if command not in commands:
        print(f"Unknown command: {command}\n")
        print(__doc__)
        return

    commands[command]()


if __name__ == "__main__":
    main()
