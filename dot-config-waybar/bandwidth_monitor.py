#!/usr/bin/env python3
import json
import os
import sys
import time
from datetime import datetime

INTERFACE = "wlp2s0"
DATA_FILE = os.path.expanduser("~/.cache/waybar_bandwidth.json")

def get_interface_stats(interface):
    try:
        with open("/proc/net/dev", "r") as f:
            lines = f.readlines()
            for line in lines:
                if interface in line:
                    # Format: wlp2s0: 3674279    4853 ...
                    parts = line.split(":")[1].split()
                    return int(parts[0]), int(parts[9])
    except Exception:
        pass
    return None, None

def load_data():
    if os.path.exists(DATA_FILE):
        try:
            with open(DATA_FILE, "r") as f:
                return json.load(f)
        except Exception:
            pass
    return {
        "mode": "daily",
        "last_rx": 0,
        "last_tx": 0,
        "last_time": 0,
        "last_day": "",
        "last_week": "",
        "daily_rx": 0,
        "daily_tx": 0,
        "weekly_rx": 0,
        "weekly_tx": 0
    }

def save_data(data):
    os.makedirs(os.path.dirname(DATA_FILE), exist_ok=True)
    with open(DATA_FILE, "w") as f:
        json.dump(data, f)

def main():
    data = load_data()
    
    if len(sys.argv) > 1 and sys.argv[1] == "--toggle":
        data["mode"] = "weekly" if data["mode"] == "daily" else "daily"
        save_data(data)
        return

    rx_cur, tx_cur = get_interface_stats(INTERFACE)
    if rx_cur is None:
        print(json.dumps({"text": "net err", "class": "error"}))
        return

    now = int(time.time())
    today = datetime.now().strftime("%Y-%m-%d")
    this_week = datetime.now().strftime("%Y-%W")

    # Handle counter reset (reboot)
    if rx_cur < data["last_rx"] or tx_cur < data["last_tx"]:
        delta_rx = rx_cur
        delta_tx = tx_cur
    else:
        delta_rx = rx_cur - data["last_rx"]
        delta_tx = tx_cur - data["last_tx"]

    # Day change
    if today != data["last_day"]:
        data["daily_rx"] = 0
        data["daily_tx"] = 0
        data["last_day"] = today

    # Week change
    if this_week != data["last_week"]:
        data["weekly_rx"] = 0
        data["weekly_tx"] = 0
        data["last_week"] = this_week

    data["daily_rx"] += delta_rx
    data["daily_tx"] += delta_tx
    data["weekly_rx"] += delta_rx
    data["weekly_tx"] += delta_tx
    data["last_rx"] = rx_cur
    data["last_tx"] = tx_cur
    data["last_time"] = now

    save_data(data)

    # Format output
    mode = data["mode"]
    if mode == "daily":
        rx_mb = data["daily_rx"] / (1024 * 1024)
        tx_mb = data["daily_tx"] / (1024 * 1024)
        text = f"[ ↓{rx_mb:.2f}M ↑{tx_mb:.2f}M ]"
    else:
        rx_mb = data["weekly_rx"] / (1024 * 1024)
        tx_mb = data["weekly_tx"] / (1024 * 1024)
        text = f"[ ↓{rx_mb:.2f}M ↑{tx_mb:.2f}M ] (W)"

    tooltip = (
        f"Mode: {mode}\n"
        f"Daily RX: {data['daily_rx']/(1024*1024):.2f} MB\n"
        f"Daily TX: {data['daily_tx']/(1024*1024):.2f} MB\n"
        f"Weekly RX: {data['weekly_rx']/(1024*1024):.2f} MB\n"
        f"Weekly TX: {data['weekly_tx']/(1024*1024):.2f} MB"
    )

    print(json.dumps({"text": text, "tooltip": tooltip}))

if __name__ == "__main__":
    main()
