#!/usr/bin/env python3
"""
qbt-prune-seeded.py — remove torrents that have seeded longer than N days.

  Dry-run (default):        ./qbt-prune-seeded.py
  Different threshold:      ./qbt-prune-seeded.py --days 14
  Select by age instead:    ./qbt-prune-seeded.py --basis age      # wall-clock since completion
  Actually remove:          ./qbt-prune-seeded.py --apply
  Remove AND delete files:  ./qbt-prune-seeded.py --apply --delete-files   # DANGEROUS, see below

Auth: --user/--pass or QBT_USER / QBT_PASS env vars.

  --basis seedtime (default): qBittorrent's accumulated *active* seeding time
                              (same field its share limits use; pauses when paused).
  --basis age:                wall-clock time since the download completed.

WARNING on --delete-files: in a hardlink + cross-seed setup, qBit deleting the
content can orphan cross-seeded copies and yank files out from under the media
library. Default is OFF (torrent removed, files left on disk). Only flip it on if
you know the selected torrents aren't cross-seeded / hardlinked.

Also: removing a torrent before its tracker's minimum seed time / ratio is met can
earn a hit-and-run. The dry-run prints seed time + ratio so you can eyeball that first.
"""

import argparse
import os
import re
import sys
import time

try:
    import requests
except ImportError:
    sys.exit("requests not installed:  pip install requests")


class QbtClient:
    def __init__(self, base, user, pwd):
        self.base = base.rstrip("/")
        self.s = requests.Session()
        r = self.s.post(f"{self.base}/api/v2/auth/login",
                        data={"username": user, "password": pwd},
                        headers={"Referer": self.base}, timeout=15)
        body = r.text.strip()
        if body == "Fails.":
            sys.exit("Login failed: wrong username/password.")
        if r.status_code == 403:
            sys.exit("Login failed: 403 (temporarily banned — wait a few min).")
        if body != "Ok.":
            # proxy / bypass-auth setups can return 204 empty; confirm via a probe.
            v = self.s.get(f"{self.base}/api/v2/app/version", timeout=15)
            if v.status_code == 200 and re.match(r"v?\d+\.\d+", v.text.strip()):
                print(f"Note: login returned {r.status_code} {body!r}; API open anyway "
                      f"(qBittorrent {v.text.strip()}) — continuing.")
            else:
                sys.exit(f"Login returned {r.status_code} {body!r} and probe failed "
                         f"({v.status_code}). Check WebUI auth / proxy.")

    def torrents(self):
        r = self.s.get(f"{self.base}/api/v2/torrents/info", timeout=30)
        r.raise_for_status()
        return r.json()

    def delete(self, hashes, delete_files):
        r = self.s.post(f"{self.base}/api/v2/torrents/delete",
                        data={"hashes": "|".join(hashes),
                              "deleteFiles": "true" if delete_files else "false"},
                        headers={"Referer": self.base}, timeout=60)
        return r.status_code, r.text.strip()


def seed_seconds(t, basis):
    if basis == "age":
        c = t.get("completion_on", 0) or 0
        return (time.time() - c) if c > 0 else 0
    return t.get("seeding_time", 0) or 0


def main():
    ap = argparse.ArgumentParser(description="Remove torrents seeded longer than N days.")
    ap.add_argument("--url", default=os.environ.get("QBT_URL", "https://qbittorrent.domatesis.com"))
    ap.add_argument("--user", default=os.environ.get("QBT_USER"))
    ap.add_argument("--pass", dest="pwd", default=os.environ.get("QBT_PASS"))
    ap.add_argument("--days", type=float, default=10, help="threshold in days (default: 10)")
    ap.add_argument("--basis", choices=("seedtime", "age"), default="seedtime",
                    help="seedtime = active seeding time (default); age = since completion")
    ap.add_argument("--category", help="only consider torrents in this category")
    ap.add_argument("--apply", action="store_true", help="actually remove (default is dry-run)")
    ap.add_argument("--delete-files", action="store_true",
                    help="also delete content from disk — DANGEROUS with hardlinks/cross-seed")
    args = ap.parse_args()

    if not args.user or not args.pwd:
        sys.exit("Provide --user/--pass or set QBT_USER / QBT_PASS.")

    threshold = args.days * 86400
    client = QbtClient(args.url, args.user, args.pwd)
    torrents = client.torrents()
    if args.category:
        torrents = [t for t in torrents if t.get("category") == args.category]

    selected = []
    for t in torrents:
        secs = seed_seconds(t, args.basis)
        if secs > threshold:
            selected.append((t, secs))
    selected.sort(key=lambda x: x[1], reverse=True)

    print(f"Connected to {args.url} — {len(torrents)} torrents scanned"
          f"{f' in category {args.category!r}' if args.category else ''}.")
    print(f"basis={args.basis}  threshold={args.days}d  matched={len(selected)}\n")

    for t, secs in selected:
        flag = "[del]" if args.apply else "[dry]"
        print(f"  {flag} {secs/86400:6.1f}d  ratio {t.get('ratio', 0):5.2f}  "
              f"{t['name'][:60]}")

    if not selected:
        print("Nothing over the threshold.")
        return

    if not args.apply:
        print(f"\nDry-run. Re-run with --apply to remove these {len(selected)} torrents"
              f"{' (files kept)' if not args.delete_files else ' AND DELETE FILES'}.")
        return

    hashes = [t["hash"] for t, _ in selected]
    code, msg = client.delete(hashes, args.delete_files)
    ok = 200 <= code < 300
    print(f"\nDelete request: {code} {'ok' if ok else 'FAILED ' + msg}  "
          f"({len(hashes)} torrents, files {'DELETED' if args.delete_files else 'kept'})")


if __name__ == "__main__":
    main()
