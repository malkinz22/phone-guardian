# Phone Guardian

A lightweight anti-theft / "find my phone" toolkit for Android, built with
**Python + Termux**. It runs entirely on your own device — no cloud
service, no company holding your data. Alerts are delivered to you via a
private Telegram bot.

## Features

- **Location report** — get GPS coordinates + a Google Maps link sent to your Telegram
- **Panic trigger** — sounds a loud alarm, snaps a photo with the front camera, and texts you the location, all in one command
- **SIM-swap detection** — alerts you if the SIM card is changed (common first move by a thief)
- **Remote trigger via SMS** — send a secret keyword text to the phone to trigger the panic sequence even if you have no other access to it

## How it works

Everything is driven by [Termux:API](https://wiki.termux.com/wiki/Termux:API),
which exposes native Android functions (GPS, camera, SMS, notifications,
vibration) to the command line. This project is just Python scripts that
call those commands and forward the results to a Telegram bot you control.

## Requirements

- An Android phone
- [Termux](https://f-droid.org/packages/com.termux/) (install from F-Droid — the Play Store version is outdated)
- [Termux:API](https://f-droid.org/packages/com.termux.api/) app (same developer, from F-Droid)
- A free Telegram bot (instructions below)

> Install Termux and Termux:API from **F-Droid**, not the Play Store. The Play Store builds are unmaintained and commonly break.

## Setup

### 1. Install Termux packages

```bash
pkg update && pkg upgrade
pkg install python git termux-api
```

### 2. Grant permissions

Open the **Termux:API** app once so Android registers it, then grant it
Location, Camera, and SMS permissions in your phone's Settings → Apps →
Termux:API → Permissions.

### 3. Create a Telegram bot (for alerts)

1. In Telegram, message **@BotFather** → `/newbot` → follow the prompts.
2. BotFather gives you a **bot token** — save it.
3. Message your new bot anything (e.g. "hi") so it can message you back.
4. Visit `https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates` in a browser
   and find your **chat id** in the JSON response (`"chat":{"id": ...}`).

### 4. Clone this project onto your phone

```bash
git clone https://github.com/YOUR_USERNAME/phone-guardian.git
cd phone-guardian
```

### 5. Configure

```bash
cp config.example.json config.json
nano config.json   # paste in your bot token and chat id, then Ctrl+O, Enter, Ctrl+X
```

### 6. Test it

```bash
python main.py report      # should send your current location to Telegram
python main.py baseline-sim  # saves your current SIM as "trusted"
python main.py panic       # should alarm, snap a photo, and message you
```

## Usage

| Command | What it does |
|---|---|
| `python main.py report` | Sends a one-off location report |
| `python main.py panic` | Full panic sequence: alarm + photo + location |
| `python main.py baseline-sim` | Saves current SIM as the trusted baseline (run this once, right after setup) |
| `python main.py check-sim` | Compares current SIM to baseline, alerts if changed |
| `python main.py watch` | Runs continuously, watching for a trigger SMS (see below) |

### Remote trigger via SMS

If your phone is stolen, you likely won't have the Termux app open on it.
`watch` mode polls for incoming texts containing a keyword
(default: `GUARDIAN PANIC`) and runs the panic sequence automatically. Start
it before you hand your phone off to risk (or run it persistently — see
below), then if the phone goes missing, text `GUARDIAN PANIC` to it from
any other phone.

### Running automatically in the background

Use `termux-job-scheduler` or Termux's `Termux:Boot` add-on app to start
`watch` mode or periodic `check-sim` calls automatically. Example, to run
a SIM check every 15 minutes via cron-style scheduling:

```bash
pkg install termux-services cronie
crontab -e
# add this line:
*/15 * * * * cd ~/phone-guardian && python main.py check-sim
```

## Uploading this project to GitHub

If you're setting this up fresh on your computer (not the phone) and want
to push it to your own GitHub:

```bash
cd phone-guardian
git init
git add .
git commit -m "Initial commit: Phone Guardian anti-theft toolkit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/phone-guardian.git
git push -u origin main
```

**Important:** `config.json` and `sim_state.json` are already excluded via
`.gitignore` — double check they're never committed, since `config.json`
contains your Telegram bot token. If you ever accidentally commit it,
revoke the bot token via @BotFather (`/revoke`) and generate a new one.

## Project structure

```
phone-guardian/
├── main.py                    # CLI entry point
├── modules/
│   ├── location.py            # GPS lookup via termux-location
│   ├── camera_capture.py      # Silent photo capture
│   ├── alarm.py                # Loud alarm + vibration + notification
│   ├── sim_watch.py           # SIM-swap detection
│   └── notifier.py            # Telegram messaging
├── config.example.json        # Template - copy to config.json
├── requirements.txt
├── .gitignore
└── README.md
```

## Limitations & honest notes

- This relies on the phone still having battery, data/wifi, and not being
  factory reset. It won't recover a phone that's powered off or reset —
  pair it with your phone's built-in **Find My Device** (Google) or **Find
  My iPhone** as your primary line of defense; this project is a
  supplementary layer, not a replacement.
- SIM-swap detection isn't foolproof across all carriers/Android versions,
  since some devices don't populate every telephony field.
- This project is meant to protect **your own** device. Please don't
  install it on someone else's phone without their knowledge — that
  crosses into stalkerware territory, which is both unethical and illegal
  in most jurisdictions.

## License

MIT — do whatever you want with it.
