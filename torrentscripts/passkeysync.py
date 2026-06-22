#!/usr/bin/env python3
"""
qbt-passkey-sync.py — scan every torrent in qBittorrent and normalize tracker passkeys.

Workflow:
  1) Discover what's out there:   ./qbt-passkey-sync.py --discover
  2) Fill CURRENT_PASSKEYS (or --keys keys.json), then dry-run (default):
                                  ./qbt-passkey-sync.py
  3) Apply once the diff looks right:
                                  ./qbt-passkey-sync.py --apply

Auth: pass --user/--pass, or set QBT_USER / QBT_PASS env vars (avoids shell history).

Caveat: handles single-secret trackers (passkey/authkey/torrent_pass/pid/key in the
query, or  /<passkey>/announce  in the path). Gazelle-style trackers that use TWO
secrets (authkey + torrent_pass that rotate together) are only partially handled —
verify those by hand in --discover output before applying.

NB (qBittorrent v5.2.x / Web API v2.15.x): editTracker's old `origUrl` parameter was
renamed to `url`, and `newUrl` became optional. This script sends BOTH `url` and
`origUrl` so it works against old and new qBittorrent alike (each version reads its
own param and ignores the unknown one).
"""

import argparse
import os
import re
import sys
import json
from collections import defaultdict, Counter
from urllib.parse import urlparse, parse_qs, urlencode, urlunparse

try:
    import requests
except ImportError:
    sys.exit("requests not installed:  pip install requests   (or: pipx run …)")

# ---------------------------------------------------------------------------
# host substring  ->  current correct passkey.  Matched against the tracker netloc.
# Leave empty and use --discover first to see what keys exist per host.
CURRENT_PASSKEYS = {
    # TorrentLeech serves the same passkey across both announce hosts:
    "torrentleech.org": "ea18eafe29333871c24903bf3ec2aac8",
    "tleechreload.org": "ea18eafe29333871c24903bf3ec2aac8",
}
# ---------------------------------------------------------------------------

PASSKEY_PARAM_NAMES = ("passkey", "authkey", "torrent_pass", "pid", "key", "pass", "secret_key")


def find_passkey(url):
    """Locate the passkey token in a tracker URL.
    Returns (token, rebuild_fn) where rebuild_fn(new_token) -> new_url, or (None, None)."""
    parsed = urlparse(url)

    # 1) query-param style:  ...?passkey=XXXX  /  ...?authkey=XXXX
    qs = parse_qs(parsed.query, keep_blank_values=True)
    for name in PASSKEY_PARAM_NAMES:
        if name in qs and qs[name] and qs[name][0]:
            token = qs[name][0]

            def rebuild(new, _name=name, _qs=qs, _parsed=parsed):
                nq = {k: list(v) for k, v in _qs.items()}
                nq[_name] = [new]
                return urlunparse(_parsed._replace(query=urlencode(nq, doseq=True)))

            return token, rebuild

    # 2) path style:  https://host/<passkey>/announce
    segments = parsed.path.split("/")
    if "announce" in segments:
        idx = segments.index("announce")
        if idx > 0 and re.fullmatch(r"[A-Za-z0-9]{12,64}", segments[idx - 1]):
            token = segments[idx - 1]

            def rebuild(new, _i=idx - 1, _segs=segments, _parsed=parsed):
                ns = list(_segs)
                ns[_i] = new
                return urlunparse(_parsed._replace(path="/".join(ns)))

            return token, rebuild

    return None, None


def host_match(netloc, keys):
    """Return the configured key value if any configured host substring is in netloc."""
    for host, key in keys.items():
        if host in netloc:
            return host, key
    return None, None


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
            sys.exit("Login failed: 403 (temporarily banned — too many attempts; wait a few min).")
        # Normal success is 200 "Ok." — but behind a reverse proxy / cloudflared, or with
        # "bypass auth for localhost" on, login can return 204 / empty while the API is open.
        # Confirm by probing an authed endpoint rather than trusting the login body.
        if body != "Ok.":
            v = self.s.get(f"{self.base}/api/v2/app/version", timeout=15)
            if v.status_code == 200 and re.match(r"v?\d+\.\d+", v.text.strip()):
                print(f"Note: login returned {r.status_code} {body!r}; API open anyway "
                      f"(qBittorrent {v.text.strip()}) — continuing.")
            else:
                sys.exit(f"Login returned {r.status_code} {body!r} and the API probe also "
                         f"failed ({v.status_code}). Check the WebUI auth / proxy in front of it.")

    def torrents(self):
        r = self.s.get(f"{self.base}/api/v2/torrents/info", timeout=30)
        r.raise_for_status()
        return r.json()

    def trackers(self, h):
        r = self.s.get(f"{self.base}/api/v2/torrents/trackers",
                       params={"hash": h}, timeout=30)
        r.raise_for_status()
        return r.json()

    def edit_tracker(self, h, orig, new):
        # qBittorrent v5.2.x renamed `origUrl` -> `url`; older builds still expect
        # `origUrl`. Sending both keeps this compatible with either version.
        r = self.s.post(f"{self.base}/api/v2/torrents/editTracker",
                        data={"hash": h, "url": orig, "origUrl": orig, "newUrl": new},
                        headers={"Referer": self.base}, timeout=30)
        return r.status_code, r.text.strip()


def iter_http_trackers(client, torrents):
    """Yield (torrent, tracker_url) for real http(s) trackers only."""
    for t in torrents:
        for tr in client.trackers(t["hash"]):
            url = tr.get("url", "")
            if url.startswith(("http://", "https://")):
                yield t, url


def cmd_discover(client, torrents):
    seen = defaultdict(Counter)
    example = {}
    for t, url in iter_http_trackers(client, torrents):
        netloc = urlparse(url).netloc
        token, _ = find_passkey(url)
        if token:
            seen[netloc][token] += 1
            example.setdefault((netloc, token), t["name"])
    if not seen:
        print("No passkeys detected in any tracker URL.")
        return
    for netloc in sorted(seen):
        print(f"\n{netloc}")
        for token, n in seen[netloc].most_common():
            masked = token[:6] + "…" + token[-4:] if len(token) > 12 else token
            print(f"  {n:>5}×  {masked}   e.g. {example[(netloc, token)]}")
    print("\nThe high-count key per host is almost certainly the current one;")
    print("low-count keys are the stragglers to rotate.")


def cmd_sync(client, torrents, keys, apply):
    scanned = matched = mismatched = updated = errors = 0
    for t, url in iter_http_trackers(client, torrents):
        scanned += 1
        netloc = urlparse(url).netloc
        host, current = host_match(netloc, keys)
        if not current:
            continue
        matched += 1
        token, rebuild = find_passkey(url)
        if token is None:
            print(f"  ?? could not locate passkey in: {url}  ({t['name']})")
            continue
        if token == current:
            continue
        mismatched += 1
        new_url = rebuild(current)
        old_m = token[:6] + "…" + token[-4:] if len(token) > 12 else token
        new_m = current[:6] + "…" + current[-4:] if len(current) > 12 else current
        if apply:
            code, msg = client.edit_tracker(t["hash"], url, new_url)
            ok = 200 <= code < 300
            updated += ok
            errors += (not ok)
            flag = "ok" if ok else f"ERR {code}"
            print(f"  [{flag}] {t['name'][:55]:55}  {old_m} -> {new_m}")
            if not ok:
                print(f"         orig: {url}")
                print(f"         new : {new_url}")
                if msg:
                    print(f"         resp: {msg}")
        else:
            print(f"  [dry] {t['name'][:55]:55}  {old_m} -> {new_m}")

    print(f"\nscanned trackers: {scanned}  | matched host: {matched}  | "
          f"mismatched: {mismatched}  | "
          f"{'updated' if apply else 'would update'}: {updated if apply else mismatched}"
          f"  | errors: {errors}")
    if not apply and mismatched:
        print("Re-run with --apply to write these changes.")


def main():
    ap = argparse.ArgumentParser(description="Normalize qBittorrent tracker passkeys.")
    ap.add_argument("--url", default=os.environ.get("QBT_URL", "https://qbittorrent.domatesis.com"),
                    help="qBittorrent WebUI base URL (default: %(default)s)")
    ap.add_argument("--user", default=os.environ.get("QBT_USER"))
    ap.add_argument("--pass", dest="pwd", default=os.environ.get("QBT_PASS"))
    ap.add_argument("--keys", help="JSON file of {host: passkey}; overrides inline CURRENT_PASSKEYS")
    ap.add_argument("--discover", action="store_true",
                    help="just list distinct passkeys per tracker host, then exit")
    ap.add_argument("--apply", action="store_true",
                    help="actually edit trackers (default is dry-run)")
    args = ap.parse_args()

    if not args.user or not args.pwd:
        sys.exit("Provide --user/--pass or set QBT_USER / QBT_PASS.")

    keys = CURRENT_PASSKEYS
    if args.keys:
        with open(args.keys) as f:
            keys = json.load(f)

    client = QbtClient(args.url, args.user, args.pwd)
    torrents = client.torrents()
    print(f"Connected to {args.url} — {len(torrents)} torrents.")

    if args.discover:
        cmd_discover(client, torrents)
        return

    if not keys:
        sys.exit("CURRENT_PASSKEYS is empty. Run --discover first, then fill it in (or use --keys).")

    cmd_sync(client, torrents, keys, args.apply)


if __name__ == "__main__":
    main()
