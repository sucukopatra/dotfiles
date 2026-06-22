#!/usr/bin/env python3
"""
Download .torrent files for the FREELEECH torrents on your TorrentLeech
Hit-and-Run list.

For each torrent on your HnR list it opens the torrent's detail page,
checks for the system freeleech badge (class "labelfreeleech"), and only
for those downloads the .torrent (using the real download link on the
page). Writes _freeleech_evidence.txt so you can confirm every match.

Does NOT add anything to a client and does NOT download torrent content.
Stdlib only. Run: python3 tl-hnr-grab.py
"""

import os
import re
import sys
import time
import urllib.request
import urllib.error

# ---- CONFIG ------------------------------------------------------------
PROFILE_USER = "sucukopatra"
HNR_URL = f"https://www.torrentleech.org/profile/{PROFILE_USER}/hnr"
OUT_DIR = "./tl-hnr-torrents"
DELAY = 1.0   # seconds between requests -- be gentle on the tracker
# ------------------------------------------------------------------------

# Paste your full browser Cookie header here.
COOKIE = "tlpass=2109260%3A1783602048%3A6f6a2d477180398f62d20d9682f64974dec6f2a9ca7845e200324ee231fecafb%3A26f1f33aa29271abbf5f90cc023d75413ee9f66ac31565e79a3855776886d732; tluid=2109260"
# ------------------------------------------------------------------------

BASE = "https://www.torrentleech.org"
HEADERS = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) "
                  "Gecko/20100101 Firefox/128.0",
    "Cookie": COOKIE,
    "Accept": "text/html,application/xhtml+xml",
}

HNR_ID_RE = re.compile(r"window\.location='/torrent/(\d+)'")
FL_RE = re.compile(r"labelfreeleech", re.I)             # system freeleech badge
DL_RE = re.compile(r'href="(/download/\d+/[^"]+\.torrent)"')
TITLE_RE = re.compile(r'id="torrentnameid"[^>]*>(.*?)</h2>', re.DOTALL | re.I)


def get(url):
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req, timeout=30) as r:
        return r.read()


def main():
    if not COOKIE:
        sys.exit("ERROR: set COOKIE first.")
    os.makedirs(OUT_DIR, exist_ok=True)

    hnr = get(HNR_URL).decode("utf-8", "replace")
    with open(os.path.join(OUT_DIR, "_hnr_page.html"), "w",
              encoding="utf-8") as f:
        f.write(hnr)
    if "/profile/" not in hnr and "login" in hnr.lower():
        sys.exit("ERROR: looks logged out -- cookie missing or expired.")

    ids = list(dict.fromkeys(HNR_ID_RE.findall(hnr)))  # ordered, unique
    if not ids:
        sys.exit("No torrent IDs found on the HnR page. Send me _hnr_page.html.")
    print(f"{len(ids)} torrents on HnR list. Checking each for freeleech...\n")

    evidence = []
    saved = skipped = errored = 0

    for i, tid in enumerate(ids, 1):
        try:
            page = get(f"{BASE}/torrent/{tid}").decode("utf-8", "replace")
        except Exception as e:
            print(f"[{i}/{len(ids)}] {tid:>10}  ERROR fetching page: {e}")
            errored += 1
            time.sleep(DELAY)
            continue

        title_m = TITLE_RE.search(page)
        title = re.sub(r"<[^>]+>", "", title_m.group(1)).strip() if title_m else "?"

        if not FL_RE.search(page):
            print(f"[{i}/{len(ids)}] {tid:>10}  not freeleech, skip")
            evidence.append(f"{tid}\tNON-FL\t{title}")
            skipped += 1
            time.sleep(DELAY)
            continue

        dl = DL_RE.search(page)
        if not dl:
            print(f"[{i}/{len(ids)}] {tid:>10}  FREELEECH but no download link!")
            evidence.append(f"{tid}\tFL-NOLINK\t{title}")
            errored += 1
            time.sleep(DELAY)
            continue

        url = BASE + dl.group(1)
        name = url.rstrip("/").split("/")[-1]
        dest = os.path.join(OUT_DIR, name)
        try:
            data = get(url)
            if data[:1] != b"d":  # bencoded .torrent files start with 'd'
                print(f"[{i}/{len(ids)}] {tid:>10}  FREELEECH but file not a "
                      f".torrent, skip")
                evidence.append(f"{tid}\tFL-BADFILE\t{title}")
                errored += 1
            else:
                with open(dest, "wb") as f:
                    f.write(data)
                print(f"[{i}/{len(ids)}] {tid:>10}  FREELEECH -> {name}")
                evidence.append(f"{tid}\tFREELEECH\t{name}\t{title}")
                saved += 1
        except Exception as e:
            print(f"[{i}/{len(ids)}] {tid:>10}  download error: {e}")
            evidence.append(f"{tid}\tFL-DLERR\t{title}")
            errored += 1
        time.sleep(DELAY)

    with open(os.path.join(OUT_DIR, "_freeleech_evidence.txt"), "w",
              encoding="utf-8") as f:
        f.write("id\tstatus\tname/title\n")
        f.write("\n".join(evidence) + "\n")

    print(f"\nDone. {saved} freeleech saved, {skipped} skipped, "
          f"{errored} errors. Files + _freeleech_evidence.txt in {OUT_DIR}")


if __name__ == "__main__":
    main()
