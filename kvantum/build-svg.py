#!/usr/bin/env python3
"""Draws kvantum/Mizu/Mizu.svg — every widget piece the Kvantum (Qt) theme uses, as flat
squares in the waybar palette. Run it again after changing a colour:  ./build-svg.py
The matching sizes, margins and text colours are in Mizu/Mizu.kvconfig."""
from pathlib import Path

BG      = "#070708"   # window
BASE    = "#0B0B0D"   # inputs, lists
ALT     = "#131315"   # buttons, hover
HOVER   = "#1B1B20"
PRESS   = "#2A2A32"
LINE    = "#2E2E37"   # passive dividers
BORDER  = "#4D4D5A"   # controls, menus
DIM     = "#7C7C84"
ACCENT  = "#BABAC6"
FG      = "#E3E2E9"

out = []
x = [0]   # every element gets its own column


def rect(i, w, h, fill, dx=0, dy=0):
    op = "" if fill else ' fill-opacity="0"'
    return f'<rect id="{i}" x="{x[0] + dx}" y="{dy}" width="{w}" height="{h}" fill="{fill or "#000"}"{op}/>'


def frame(name, border=None, fill=None, t=1, **sides):
    """Nine pieces: a t-px frame (one colour, or per side: top= bottom= left= right=) and an interior."""
    c = {s: sides.get(s, border) for s in ("top", "bottom", "left", "right")}
    n = 10
    out.append(rect(f"{name}-topleft", t, t, c["top"] or c["left"]))
    out.append(rect(f"{name}-top", n, t, c["top"], t))
    out.append(rect(f"{name}-topright", t, t, c["top"] or c["right"], t + n))
    out.append(rect(f"{name}-left", t, n, c["left"], 0, t))
    out.append(rect(name, n, n, fill, t, t))
    out.append(rect(f"{name}-right", t, n, c["right"], t + n, t))
    out.append(rect(f"{name}-bottomleft", t, t, c["bottom"] or c["left"], 0, t + n))
    out.append(rect(f"{name}-bottom", n, t, c["bottom"], t, t + n))
    out.append(rect(f"{name}-bottomright", t, t, c["bottom"] or c["right"], t + n, t + n))
    x[0] += n + 2 * t + 4


def shape(name, size, body):
    """A drawing inside an invisible size x size box, so it keeps its proportions when scaled."""
    out.append(f'<g id="{name}" transform="translate({x[0]},0)">'
               f'<rect width="{size}" height="{size}" fill="#000" fill-opacity="0"/>{body}</g>')
    x[0] += size + 4


def states(name, fn, **colours):
    for state, colour in colours.items():
        fn(f"{name}-{state}", colour)


# buttons, tool buttons (flat until hovered), text inputs
frame("button-normal",  BORDER, ALT)
frame("button-focused", ACCENT, HOVER)
frame("button-pressed", ACCENT, PRESS)
frame("button-toggled", ACCENT, ACCENT)
frame("tbutton-normal")
frame("tbutton-focused", BORDER, HOVER)
frame("tbutton-pressed", ACCENT, PRESS)
frame("tbutton-toggled", BORDER, PRESS)
frame("lineedit-normal",  BORDER, BASE)
frame("lineedit-focused", ACCENT, BASE)

# passive frames
frame("common-normal",   BORDER)
frame("common-focused",  BORDER)
frame("group-normal",    LINE)
frame("tabframe-normal", LINE)
frame("dock-normal",     LINE, BG)
frame("dock-focused",    LINE, BG)
frame("focus",           ACCENT)
frame("tooltip-normal",  BORDER, BG)

# tabs: the open one is underlined like the focused workspace on the bar
frame("tab-normal",  t=2)
frame("tab-focused", fill=ALT, t=2)
frame("tab-toggled", fill=BG, t=2, bottom=ACCENT)

# menus and lists: the selected row is inverted, as in rofi
frame("menu-normal", BORDER, BG)
frame("menubar-normal", fill=BG, bottom=LINE)
frame("toolbar-normal", fill=BG)
for s in ("focused", "pressed", "toggled"):
    frame(f"menuitem-{s}", ACCENT, ACCENT)
frame("menubaritem-focused", HOVER, HOVER)
frame("menubaritem-pressed", ACCENT, ACCENT)
frame("menubaritem-toggled", ACCENT, ACCENT)
frame("itemview-focused", ALT, ALT)
frame("itemview-pressed", ACCENT, ACCENT)
frame("itemview-toggled", ACCENT, ACCENT)
frame("header-normal",  fill=BASE,  bottom=LINE)
frame("header-focused", fill=ALT,   bottom=LINE)
frame("header-pressed", fill=HOVER, bottom=LINE)
frame("header-toggled", fill=ALT,   bottom=ACCENT)
out.append(rect("header-separator", 1, 10, LINE)); x[0] += 5

# progress bars, sliders, scrollbars
frame("progress-normal", BORDER, BASE)
frame("progress-pattern-normal",   ACCENT, ACCENT)
frame("progress-pattern-disabled", BORDER, BORDER)
frame("slider-normal",  LINE,   LINE)
frame("slider-toggled", ACCENT, ACCENT)
states("slidercursor", lambda n, c: shape(n, 14, f'<rect width="14" height="14" fill="{c}"/>'),
       normal=ACCENT, focused=FG, pressed=FG, disabled=BORDER)
frame("scrollbarslider-normal",  BORDER, BORDER)
frame("scrollbarslider-focused", DIM,    DIM)
frame("scrollbarslider-pressed", ACCENT, ACCENT)

# check boxes (square) and radio buttons (round, so the two can be told apart)
def box(n, border, fill, mark=""):
    shape(n, 16, f'<rect width="16" height="16" fill="{border}"/>'
                 f'<rect x="1" y="1" width="14" height="14" fill="{fill}"/>{mark}')

def radio(n, border, fill, dot=""):
    shape(n, 16, f'<circle cx="8" cy="8" r="8" fill="{border}"/><circle cx="8" cy="8" r="7" fill="{fill}"/>{dot}')

TICK = f'<path d="M3.5 8.5 L6.5 11.5 L12.5 4.5" stroke="{BG}" stroke-width="2" fill="none"/>'
DASH = f'<rect x="4" y="7" width="8" height="2" fill="{BG}"/>'
DOT  = f'<circle cx="8" cy="8" r="3" fill="{BG}"/>'
for s, border in (("normal", BORDER), ("focused", ACCENT), ("pressed", ACCENT)):
    box(f"checkbox-{s}", border, BASE)
    box(f"checkbox-checked-{s}",  ACCENT, ACCENT, TICK)
    box(f"checkbox-tristate-{s}", ACCENT, ACCENT, DASH)
    radio(f"radio-{s}", border, BASE)
    radio(f"radio-checked-{s}", ACCENT, ACCENT, DOT)

# arrows; "plus" / "minus" are the collapsed / expanded markers in trees
ARROWS = {"up": "1,6 4,2 7,6", "down": "1,2 4,6 7,2", "left": "6,1 2,4 6,7", "right": "2,1 6,4 2,7"}
ARROWS["plus"], ARROWS["minus"] = ARROWS["right"], ARROWS["down"]
for prefix in ("arrow", "flat-arrow", "tree", "spin"):
    for d, pts in ARROWS.items():
        states(f"{prefix}-{d}", lambda n, c, pts=pts: shape(n, 8, f'<polygon points="{pts}" fill="{c}"/>'),
               normal=FG, focused=ACCENT, pressed=ACCENT, disabled=BORDER)
for d in ("left", "right"):   # submenu arrows: dark on the inverted, selected row
    states(f"menuitem-{d}", lambda n, c, d=d: shape(n, 8, f'<polygon points="{ARROWS[d]}" fill="{c}"/>'),
           normal=FG, focused=BG, pressed=BG, toggled=BG)

# small parts
def dots(n, c):
    shape(n, 8, "".join(f'<rect x="3" y="{y}" width="2" height="2" fill="{c}"/>' for y in (0, 3, 6)))

states("splitter-grip", dots, normal=BORDER, focused=ACCENT, pressed=ACCENT)
dots("toolbar-handle", BORDER)
shape("toolbar-separator", 9, f'<rect x="4" width="1" height="9" fill="{LINE}"/>')   # hairline in a wider box, so it stays thin
states("resize-grip", lambda n, c: shape(n, 8, f'<polygon points="8,0 8,8 0,8" fill="{c}"/>'),
       normal=BORDER, focused=ACCENT)
shape("dial", 32, f'<circle cx="16" cy="16" r="16" fill="{BORDER}"/><circle cx="16" cy="16" r="15" fill="{ALT}"/>')
shape("dial-handle", 32, f'<rect x="15" y="2" width="2" height="9" fill="{ACCENT}"/>')
shape("dial-notches", 32, "")
MDI = {"close": '<path d="M2 2 L8 8 M8 2 L2 8" stroke="{c}" stroke-width="1.5"/>',
       "maximize": '<rect x="2" y="2" width="6" height="6" stroke="{c}" fill="none"/>',
       "restore": '<rect x="3" y="3" width="4" height="4" stroke="{c}" fill="none"/>',
       "minimize": '<rect x="2" y="7" width="6" height="1.5" fill="{c}"/>',
       "shade": '<polygon points="2,7 5,3 8,7" fill="{c}"/>',
       "menu": '<polygon points="2,3 8,3 5,7" fill="{c}"/>'}
for kind, body in MDI.items():
    states(f"mdi-{kind}", lambda n, c, body=body: shape(n, 10, body.format(c=c)),
           normal=FG, focused=ACCENT, pressed=ACCENT, disabled=BORDER)
out.append(rect("titlebar-normal", 10, 10, BG)); x[0] += 14
out.append(rect("titlebar-focused", 10, 10, ALT)); x[0] += 14

svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{x[0]}" height="40" viewBox="0 0 {x[0]} 40">\n'
       + "\n".join(out) + "\n</svg>\n")
target = Path(__file__).resolve().parent / "Mizu" / "Mizu.svg"
target.write_text(svg)
print(f"{target}: {len(out)} elements")
