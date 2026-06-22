#!/usr/bin/env python3
"""
Sum the total content size of every .torrent file in a folder -- i.e. how
much disk space their contents will occupy once fully downloaded.

Reads sizes straight from each .torrent's metadata. Does not touch the
network and does not download anything. Stdlib only.

Usage:
    python3 torrent-size.py [folder]      (default: ./tl-hnr-torrents)
"""

import os
import sys


def bdecode(data, pos=0):
    t = data[pos:pos + 1]
    if t == b"i":
        end = data.index(b"e", pos)
        return int(data[pos + 1:end]), end + 1
    if t == b"l":
        pos += 1
        out = []
        while data[pos:pos + 1] != b"e":
            v, pos = bdecode(data, pos)
            out.append(v)
        return out, pos + 1
    if t == b"d":
        pos += 1
        out = {}
        while data[pos:pos + 1] != b"e":
            k, pos = bdecode(data, pos)
            v, pos = bdecode(data, pos)
            out[k] = v
        return out, pos + 1
    if t.isdigit():
        colon = data.index(b":", pos)
        n = int(data[pos:colon])
        start = colon + 1
        return data[start:start + n], start + n
    raise ValueError(f"bad bencode byte {t!r} at {pos}")


def torrent_size(path):
    with open(path, "rb") as f:
        meta, _ = bdecode(f.read())
    info = meta[b"info"]
    if b"files" in info:
        return sum(fobj[b"length"] for fobj in info[b"files"])
    return info[b"length"]


def human(n):
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if n < 1024 or unit == "TB":
            return f"{n:.2f} {unit}"
        n /= 1024


def main():
    folder = sys.argv[1] if len(sys.argv) > 1 else "./tl-hnr-torrents"
    files = sorted(f for f in os.listdir(folder) if f.endswith(".torrent"))
    if not files:
        sys.exit(f"No .torrent files in {folder}")

    total = 0
    rows = []
    for name in files:
        try:
            sz = torrent_size(os.path.join(folder, name))
            total += sz
            rows.append((sz, name))
        except Exception as e:
            rows.append((-1, f"{name}  (unreadable: {e})"))

    rows.sort(reverse=True)  # biggest first
    for sz, name in rows:
        label = human(sz) if sz >= 0 else "  ERROR"
        print(f"  {label:>11}  {name}")

    print("-" * 60)
    print(f"  {len(files)} torrents, total content: {human(total)} "
          f"({total:,} bytes)")

    # Show free space on the disk holding the folder, for comparison.
    try:
        st = os.statvfs(folder)
        free = st.f_bavail * st.f_frsize
        print(f"  Free space on {os.path.abspath(folder)}'s disk: {human(free)}")
        if total > free:
            print("  WARNING: total exceeds free space here.")
    except Exception:
        pass


if __name__ == "__main__":
    main()
