"""
notifier.py
Sends alerts (text + optional photo) to a Telegram bot.
Telegram is used because it's free, works over any mobile data connection,
and doesn't require you to expose an email/SMTP password on the phone.
"""

import json
import os
import urllib.request
import urllib.parse

CONFIG_PATH = os.path.join(os.path.dirname(__file__), "..", "config.json")


def load_config():
    if not os.path.exists(CONFIG_PATH):
        raise FileNotFoundError(
            "config.json not found. Copy config.example.json to config.json "
            "and fill in your bot token + chat id."
        )
    with open(CONFIG_PATH, "r") as f:
        return json.load(f)


def send_message(text):
    cfg = load_config()
    token = cfg["telegram_bot_token"]
    chat_id = cfg["telegram_chat_id"]

    url = f"https://api.telegram.org/bot{token}/sendMessage"
    data = urllib.parse.urlencode({"chat_id": chat_id, "text": text}).encode()

    try:
        req = urllib.request.Request(url, data=data)
        with urllib.request.urlopen(req, timeout=15) as resp:
            return resp.status == 200
    except Exception as e:
        print(f"[notifier] Failed to send message: {e}")
        return False


def send_photo(photo_path, caption=""):
    cfg = load_config()
    token = cfg["telegram_bot_token"]
    chat_id = cfg["telegram_chat_id"]

    url = f"https://api.telegram.org/bot{token}/sendPhoto"

    boundary = "----PhoneGuardianBoundary"
    with open(photo_path, "rb") as f:
        photo_data = f.read()

    body = (
        f"--{boundary}\r\n"
        f'Content-Disposition: form-data; name="chat_id"\r\n\r\n{chat_id}\r\n'
        f"--{boundary}\r\n"
        f'Content-Disposition: form-data; name="caption"\r\n\r\n{caption}\r\n'
        f"--{boundary}\r\n"
        f'Content-Disposition: form-data; name="photo"; filename="capture.jpg"\r\n'
        f"Content-Type: image/jpeg\r\n\r\n"
    ).encode() + photo_data + f"\r\n--{boundary}--\r\n".encode()

    try:
        req = urllib.request.Request(url, data=body)
        req.add_header("Content-Type", f"multipart/form-data; boundary={boundary}")
        with urllib.request.urlopen(req, timeout=30) as resp:
            return resp.status == 200
    except Exception as e:
        print(f"[notifier] Failed to send photo: {e}")
        return False
