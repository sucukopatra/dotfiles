#!/usr/bin/env python3
import os
import requests

QBIT = "https://qbittorrent.domatesis.com"
USER = os.environ.get("QBIT_USER", "admin")
PASS = os.environ.get("QBIT_PASS")  # export QBIT_PASS='...' before running

MOST_SEEDS_FIRST = True   # True = fastest/most-seeded downloads go to top of queue
DRY_RUN = True            # True = just print the order, don't actually reorder

if not PASS:
    raise SystemExit("Set QBIT_PASS env var first:  QBIT_PASS='...' ./qbsort.py")

s = requests.Session()
r = s.post(f"{QBIT}/api/v2/auth/login",
           data={"username": USER, "password": PASS},
           headers={"Referer": QBIT})

if r.status_code == 403:
    raise SystemExit("403 — Host header validation. Whitelist the domain in "
                     "Options → WebUI, or toggle it off.")
if r.text != "Ok.":
    raise SystemExit(f"Login failed (body: {r.text!r}). Likely the tunnel-IP "
                     "ban (restart qbittorrent container) or wrong password.")

torrents = s.get(f"{QBIT}/api/v2/torrents/info").json()

# unfinished only, and skip torrents whose seed count the tracker hasn't reported (-1)
pending = [t for t in torrents if t["progress"] < 1 and t["num_complete"] >= 0]

# to land the most-seeded torrent at queue position 1, push fewest→most,
# so sort ascending when we want most-first (the order is inverted on purpose)
pending.sort(key=lambda t: t["num_complete"], reverse=not MOST_SEEDS_FIRST)

if DRY_RUN:
    for i, t in enumerate(pending, 1):
        print(f"{i:3}. {t['num_complete']:5} seeds  "
              f"{t['size']/1e9:6.2f} GB  {t['name'][:55]}")
    print(f"\n[dry run] {len(pending)} torrents — set DRY_RUN = False to apply")
else:
    for t in pending:
        s.post(f"{QBIT}/api/v2/torrents/topPrio", data={"hashes": t["hash"]})
    print(f"Reordered {len(pending)} torrents "
          f"({'most' if MOST_SEEDS_FIRST else 'fewest'} seeds first)")
