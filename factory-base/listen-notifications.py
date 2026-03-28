#!/usr/bin/env python3
"""
Host-side notification listener.
Receives messages from inside the Docker container and calls notify.sh.
Started by go.sh; runs in the background until killed.
"""
import socket
import subprocess
import sys
import os

notify_script = sys.argv[1]
port = int(sys.argv[2]) if len(sys.argv) > 2 else 9999

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("0.0.0.0", port))
s.listen(5)

while True:
    conn, _ = s.accept()
    msg = b""
    while True:
        data = conn.recv(1024)
        if not data:
            break
        msg += data
    conn.close()
    text = msg.decode("utf-8", errors="replace").strip()
    if text:
        subprocess.run([notify_script, text])
