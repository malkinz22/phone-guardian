"""
net_watch.py
Monitors active network connections on the device using Termux's access
to /proc or netstat-equivalent tools. Flags connections to unfamiliar
IPs/ports so you have visibility into what's actually talking on your
network - useful for spotting a misbehaving app or unexpected traffic.

Note: without root, Termux can only see connections belonging to apps
that share its user context / what's exposed via /proc/net. This is a
monitoring and alerting tool, not a packet-level firewall - it can't
block traffic itself. For that, pair it with a non-root firewall app
like NetGuard, which uses Android's VPN API to filter connections
per-app; this script complements that by giving you an audit trail.
"""

import json
import os
import re
import subprocess

STATE_PATH = os.path.join(os.path.dirname(__file__), "..", "netwatch_state.json")


def _read_proc_net_tcp():
    """Parse /proc/net/tcp and /proc/net/tcp6 for active connections."""
    connections = []
    for path in ("/proc/net/tcp", "/proc/net/tcp6"):
        if not os.path.exists(path):
            continue
        try:
            with open(path, "r") as f:
                lines = f.readlines()[1:]  # skip header
            for line in lines:
                parts = line.split()
                if len(parts) < 4:
                    continue
                local = parts[1]
                remote = parts[2]
                state = parts[3]
                remote_ip, remote_port = _decode_addr(remote)
                local_ip, local_port = _decode_addr(local)
                if remote_ip and remote_ip not in ("0.0.0.0", "::"):
                    connections.append({
                        "local": f"{local_ip}:{local_port}",
                        "remote": f"{remote_ip}:{remote_port}",
                        "state": _TCP_STATES.get(state, state),
                    })
        except (PermissionError, OSError):
            continue
    return connections


_TCP_STATES = {
    "01": "ESTABLISHED", "02": "SYN_SENT", "03": "SYN_RECV",
    "04": "FIN_WAIT1", "05": "FIN_WAIT2", "06": "TIME_WAIT",
    "07": "CLOSE", "08": "CLOSE_WAIT", "09": "LAST_ACK",
    "0A": "LISTEN", "0B": "CLOSING",
}


def _decode_addr(hex_addr):
    """Decode a hex-encoded IP:port from /proc/net/tcp format."""
    try:
        ip_hex, port_hex = hex_addr.split(":")
        port = int(port_hex, 16)
        if len(ip_hex) == 8:  # IPv4
            b = bytes.fromhex(ip_hex)
            ip = ".".join(str(b[i]) for i in (3, 2, 1, 0))
        else:  # IPv6 - simplified, just show raw hex
            ip = ip_hex
        return ip, port
    except (ValueError, IndexError):
        return None, None


def get_connections():
    """Returns list of active connection dicts. Falls back gracefully if unreadable."""
    return _read_proc_net_tcp()


def load_known_ips():
    if not os.path.exists(STATE_PATH):
        return set()
    with open(STATE_PATH, "r") as f:
        data = json.load(f)
    return set(data.get("known_ips", []))


def save_known_ips(ip_set):
    with open(STATE_PATH, "w") as f:
        json.dump({"known_ips": sorted(ip_set)}, f, indent=2)


def check_for_new_connections():
    """
    Returns a list of remote IPs seen now that weren't in the saved baseline.
    First run establishes the baseline (returns empty list).
    """
    connections = get_connections()
    current_ips = {c["remote"].split(":")[0] for c in connections if c["remote"]}

    known = load_known_ips()
    if not known:
        save_known_ips(current_ips)
        return []

    new_ips = current_ips - known
    if new_ips:
        save_known_ips(current_ips | known)

    return sorted(new_ips)


def format_connection_report():
    connections = get_connections()
    if not connections:
        return "No active outbound connections detected."

    established = [c for c in connections if c["state"] == "ESTABLISHED"]
    lines = [f"Active connections: {len(established)}"]
    for c in established[:20]:  # cap to avoid a huge message
        lines.append(f"  {c['local']} -> {c['remote']}")
    if len(established) > 20:
        lines.append(f"  ...and {len(established) - 20} more")
    return "\n".join(lines)
