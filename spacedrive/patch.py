#!/usr/bin/env python3
"""Restyle Spacedrive 0.4.3 by patching the interface files stored inside its program file.

Spacedrive is a Tauri program: its interface (stylesheets, scripts, icons, fonts) is not on
disk but inside the executable, as a table of brotli-compressed files. Each table entry is
(name pointer, name length, data pointer, data length). This script rewrites entries:

  colours   dark theme recoloured to the waybar / GTK palette (theme/gtk.css)
  font      SF Pro Text in front of the bundled IBM Plex Sans
  icons     every icon picture turned grey (the macOS-like shapes, no blue), decorations left alone
  menu      "Reveal in file manager" removed from the right-click menus
  title     page title "Files"

A replacement that compresses smaller than the original goes into the original's place.
A larger one goes into space taken from the 42 legacy .woff fonts (the .woff2 copies of the
same fonts are what the web view actually loads); the entry's pointer is moved there.

usage:  patch.py            patch ~/.local/opt/spacedrive/usr/bin/spacedrive
        patch.py --restore  put the original back
The untouched original is kept next to it as spacedrive.orig and every run starts from it,
so the script can be run again after editing. Needs python3-Brotli and python3-Pillow.
A Spacedrive update replaces the program: delete spacedrive.orig and run this again
(the names below carry build hashes, so a new version needs them looked up again).
"""
import io
import os
import re
import struct
import sys

import brotli
from PIL import Image

BIN = os.environ.get("SPACEDRIVE_BIN") or os.path.expanduser("~/.local/opt/spacedrive/usr/bin/spacedrive")
ORIG = BIN + ".orig"

CSS = "/index-FUEr4y9T.css"
JS_EXPLORER = "/useExplorer--ESKql6I.js"

# hue, saturation, lightness — the shades from theme/gtk.css
PALETTE = {
    "accent": "240, 5%, 44%",            # #6A6A75: mid grey, white text stays readable on it
    "accent-faint": "240, 6%, 56%",
    "accent-deep": "240, 6%, 35%",
    "ink": "249, 14%, 90%",              # #E3E2E9 text
    "ink-dull": "240, 6%, 68%",
    "ink-faint": "240, 3%, 50%",         # #7C7C84
    "sidebar": "240, 7%, 3%",            # #070708 window
    "sidebar-box": "240, 5%, 8%",        # #131315
    "sidebar-line": "240, 9%, 20%",      # #2E2E37 dividers
    "sidebar-ink": "249, 14%, 90%",
    "sidebar-ink-dull": "240, 6%, 68%",
    "sidebar-ink-faint": "240, 3%, 50%",
    "sidebar-divider": "240, 9%, 12%",
    "sidebar-button": "240, 5%, 8%",
    "sidebar-selected": "240, 9%, 18%",  # #2A2A32
    "sidebar-shade": "240, 9%, 12%",
    "app": "240, 8%, 5%",                # #0B0B0D views
    "app-box": "240, 5%, 8%",
    "app-dark-box": "240, 6%, 6%",
    "app-darker-box": "240, 7%, 3%",
    "app-light-box": "240, 8%, 33%",     # #4D4D5A
    "app-overlay": "240, 5%, 8%",
    "app-input": "240, 7%, 3%",
    "app-focus": "240, 7%, 3%",
    "app-line": "240, 9%, 20%",
    "app-divider": "240, 9%, 12%",       # #1B1B20
    "app-button": "240, 5%, 8%",
    "app-hover": "240, 9%, 12%",
    "app-selected": "240, 9%, 18%",
    "app-selected-item": "240, 9%, 12%",
    "app-active": "240, 9%, 18%",
    "app-shade": "240, 15%, 0%",
    "app-frame": "240, 9%, 20%",
    "app-slider": "240, 9%, 12%",
    "app-explorer-scrollbar": "240, 8%, 33%",
    "menu": "240, 7%, 3%",
    "menu-line": "240, 9%, 20%",
    "menu-ink": "249, 14%, 90%",
    "menu-faint": "240, 6%, 68%",
    "menu-hover": "240, 9%, 18%",
    "menu-selected": "240, 9%, 18%",
    "menu-shade": "240, 5%, 0%",
}

# pictures that are decoration, not icons: left in colour
KEEP_COLOUR = re.compile(r"^/(Bloom|Ball|AppLogo|AlphaBg)")


# ---------------------------------------------------------------- reading the program file
class Elf:
    def __init__(self, data):
        self.d = data
        shoff, = struct.unpack_from("<Q", data, 0x28)
        shentsize, shnum, shstrndx = struct.unpack_from("<HHH", data, 0x3A)
        raw = [struct.unpack_from("<IIQQQQIIQQ", data, shoff + i * shentsize) for i in range(shnum)]
        stro = raw[shstrndx][4]
        self.sec = {}
        for name, _type, _flags, addr, off, size, *_ in raw:
            end = data.index(b"\0", stro + name)
            self.sec[data[stro + name:end].decode()] = (addr, off, size)

    def off(self, vaddr):
        for name in (".rodata", ".data.rel.ro"):
            addr, off, size = self.sec[name]
            if addr <= vaddr < addr + size:
                return vaddr - addr + off
        return None


def asset_table(elf):
    """name -> dict(entry: file offset of the 32-byte entry, rela: file offset of the data
    pointer's relocation record, off / len: where the compressed data is)."""
    d = elf.d
    ra, ro, rs = elf.sec[".rela.dyn"]
    da, _do, ds = elf.sec[".data.rel.ro"]
    rel = {}
    for i in range(ro, ro + rs, 24):
        where, info, addend = struct.unpack_from("<QQq", d, i)
        if info & 0xFFFFFFFF == 8 and da <= where < da + ds:   # R_X86_64_RELATIVE
            rel[where] = (addend, i)
    table = {}
    for va in sorted(rel):
        if va + 16 not in rel:
            continue
        o = elf.off(va)
        klen, = struct.unpack_from("<Q", d, o + 8)
        ko = elf.off(rel[va][0])
        if ko is None or not 1 < klen < 200:
            continue
        key = d[ko:ko + klen]
        if not re.fullmatch(rb"/[\x21-\x7e]+\.(html|js|css|png|svg|woff2?)", key):
            continue
        vlen, = struct.unpack_from("<Q", d, o + 24)
        vo = elf.off(rel[va + 16][0])
        if vo is None or vlen < 16:
            continue                      # the three empty index.html stubs
        table[key.decode()] = dict(entry=o, rela=rel[va + 16][1], vaddr=rel[va + 16][0], off=vo, len=vlen)
    return table


# ---------------------------------------------------------------- the changes
def new_css(text):
    block = re.search(r":root\{--dark-hue:[^{}]*\}", text)
    body = block.group(0)
    for name, value in PALETTE.items():
        body, n = re.subn(r"(--color-%s:)[^;}]*" % re.escape(name), r"\g<1>" + value, body)
        assert n == 1, name
    text = text[:block.start()] + body + text[block.end():]
    text, n = re.subn(r"font-family:IBM Plex Sans,", "font-family:SF Pro Text,IBM Plex Sans,", text)
    assert n >= 1
    # the page's base font is "system-ui", which depends on what GTK reports: name it outright
    text, n = re.subn(r"font-family:ui-sans-serif,", "font-family:SF Pro Text,ui-sans-serif,", text)
    assert n >= 1
    return text


def new_explorer_js(text):
    # right-click menu of a file or folder: the entry's component returns nothing
    a = 'if(!o)return null;const i=No[e]??"file manager";'
    assert text.count(a) == 1
    text = text.replace(a, 'return null;const i=No[e]??"file manager";')
    # right-click menu of a folder in the path bar: drop the entry from the list
    m = re.search(r'd\.jsx\(ne\.Item,\{onClick:\(\)=>\{if\(!i\)return null;i\(s\.uuid,.{0,140}?\},'
                  r'label:u\("revel_in_browser",\{browser:p\}\),icon:co\}\),', text)
    assert m
    return text[:m.start()] + text[m.end():]


def grey(png):
    """Same picture without its colour: brightness and transparency kept (grey + alpha PNG)."""
    im = Image.open(io.BytesIO(png)).convert("RGBA")
    r, g, b, a = im.split()
    out = Image.merge("LA", (Image.merge("RGB", (r, g, b)).convert("L"), a))
    buf = io.BytesIO()
    out.save(buf, "PNG", optimize=True)
    return buf.getvalue()


# ---------------------------------------------------------------- writing
def main():
    if "--restore" in sys.argv:
        os.replace(ORIG, BIN)
        print("original restored")
        return
    if not os.path.exists(ORIG):
        with open(BIN, "rb") as f, open(ORIG, "wb") as g:
            g.write(f.read())
        os.chmod(ORIG, 0o755)
    data = bytearray(open(ORIG, "rb").read())
    elf = Elf(data)
    table = asset_table(elf)
    get = lambda k: brotli.decompress(bytes(data[table[k]["off"]:table[k]["off"] + table[k]["len"]]))

    new = {}
    new[CSS] = new_css(get(CSS).decode()).encode()
    new[JS_EXPLORER] = new_explorer_js(get(JS_EXPLORER).decode()).encode()
    html = get("/index.html").decode()
    assert "<title>Spacedrive</title>" in html
    new["/index.html"] = html.replace("<title>Spacedrive</title>", "<title>Files</title>").encode()
    for k in table:
        if k.endswith(".png") and not KEEP_COLOUR.match(k):
            new[k] = grey(get(k))

    # spare room: the legacy .woff fonts. Their entries are pointed at the .woff2 twin.
    pool = []
    stem = lambda name: re.sub(r"-[^-]+\.woff2?$", "", name)      # name without its build hash
    woff2 = {stem(k): e for k, e in table.items() if k.endswith(".woff2")}
    for k, e in table.items():
        if k.endswith(".woff") and stem(k) in woff2:
            pool.append([e["off"], e["vaddr"], e["len"]])
            twin = woff2[stem(k)]
            struct.pack_into("<q", data, e["rela"] + 16, twin["vaddr"])
            struct.pack_into("<Q", data, e["entry"] + 24, twin["len"])
    pool.sort()
    merged = []                                   # neighbouring fonts form one larger space
    for s_ in pool:
        if merged and merged[-1][0] + merged[-1][2] == s_[0]:
            merged[-1][2] += s_[2]
        else:
            merged.append(s_)
    pool = merged

    moved = 0
    for k, raw in new.items():
        e = table[k]
        comp = brotli.compress(raw, quality=11)
        if len(comp) <= e["len"]:
            data[e["off"]:e["off"] + len(comp)] = comp
        else:
            slot = next((s for s in pool if s[2] >= len(comp)), None)
            if slot is None and k.endswith(".png"):           # last resort: 256 shades
                buf = io.BytesIO()
                Image.open(io.BytesIO(raw)).convert("RGBA").quantize(256, method=Image.Quantize.FASTOCTREE) \
                    .save(buf, "PNG", optimize=True)
                raw = new[k] = buf.getvalue()
                comp = brotli.compress(raw, quality=11)
                if len(comp) <= e["len"]:
                    data[e["off"]:e["off"] + len(comp)] = comp
                    struct.pack_into("<Q", data, e["entry"] + 24, len(comp))
                    continue
                slot = next((s for s in pool if s[2] >= len(comp)), None)
            if slot is None:
                sys.exit("no room left for %s (%d bytes)" % (k, len(comp)))
            data[slot[0]:slot[0] + len(comp)] = comp
            struct.pack_into("<q", data, e["rela"] + 16, slot[1])
            slot[0] += len(comp); slot[1] += len(comp); slot[2] -= len(comp)
            pool.append([e["off"], e["vaddr"], e["len"]])     # its old place is spare room now
            moved += 1
        struct.pack_into("<Q", data, e["entry"] + 24, len(comp))

    # check: every file in the patched table still unpacks, and the changed ones read back
    check = asset_table(Elf(data))
    for k, e in check.items():
        got = brotli.decompress(bytes(data[e["off"]:e["off"] + e["len"]]))
        assert k not in new or got == new[k], k

    tmp = BIN + ".new"
    with open(tmp, "wb") as f:
        f.write(data)
    os.chmod(tmp, 0o755)
    os.replace(tmp, BIN)
    print("patched %d files (%d moved into spare room, %d bytes of it left); original kept as %s"
          % (len(new), moved, sum(s[2] for s in pool), ORIG))


if __name__ == "__main__":
    main()
