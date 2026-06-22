#!/usr/bin/env python3
import requests

QBIT = "https://qbittorrent.domatesis.com"   # adjust to your container/host
USER = "admin"
PASS = "zeEGX%&Z9BCkMS1pm3yM"

LARGEST_FIRST = False  # True = biggest downloads first

s = requests.Session()
r = s.post(f"{QBIT}/api/v2/auth/login",
           data={"username": USER, "password": PASS},
           headers={"Referer": QBIT})
r.raise_for_status()
if r.text != "Ok.":
    raise SystemExit("Login failed — check credentials / WebUI host")

torrents = s.get(f"{QBIT}/api/v2/torrents/info").json()

# unfinished only, sorted by size
pending = [t for t in torrents if t["progress"] < 1]
pending.sort(key=lambda t: t["size"], reverse=not LARGEST_FIRST)

# push to top largest→smallest so the desired one lands at position 1
for t in pending:
    s.post(f"{QBIT}/api/v2/torrents/topPrio", data={"hashes": t["hash"]})

print(f"Reordered {len(pending)} torrents "
      f"({'largest' if LARGEST_FIRST else 'smallest'} first)")
