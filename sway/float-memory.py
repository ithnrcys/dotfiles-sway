#!/usr/bin/env python3
"""Floating windows that come back where they were left.

For the app_ids below, the position and size a window had when it closed are saved
(~/.local/state/float-memory.json) and given back to the next window of that app_id.
sway/config makes these windows float; drag them with $mod + left mouse, resize with
$mod + right mouse. Started from sway/autostart.sh, reads sway's window events.
"""
import json, os, subprocess, time

APPS = {
    "quick.notepad",                          # notes (waybar/scripts/notes.sh)
    "io.github.Go08er.GlazeMyNumbersBaby",    # calculator (GMNB flatpak)
}
STORE = os.path.expanduser("~/.local/state/float-memory.json")


def load():
    try:
        with open(STORE) as f:
            return json.load(f)
    except (OSError, ValueError):
        return {}


def save(data):
    os.makedirs(os.path.dirname(STORE), exist_ok=True)
    tmp = STORE + ".tmp"
    with open(tmp, "w") as f:
        json.dump(data, f, indent=1)
    os.replace(tmp, STORE)


def sway(cmd):
    subprocess.run(["swaymsg", cmd], capture_output=True)


def rect_of(con_id):
    tree = json.loads(subprocess.run(["swaymsg", "-t", "get_tree", "-r"],
                                     capture_output=True, text=True).stdout)
    stack = [tree]
    while stack:
        n = stack.pop()
        if n.get("id") == con_id:
            return n["rect"]
        stack += n.get("nodes", []) + n.get("floating_nodes", [])
    return None


def restore(con_id, geo):
    time.sleep(0.15)                          # let the for_window rule float it first
    sway(f"[con_id={con_id}] resize set {geo['width']} {geo['height']}")
    sway(f"[con_id={con_id}] move absolute position {geo['x']} {geo['y']}")
    # the reported rect is offset from the position given (border, bar), so measure the
    # difference once and correct for it
    got = rect_of(con_id)
    if got:
        dx, dy = geo["x"] - got["x"], geo["y"] - got["y"]
        if dx or dy:
            sway(f"[con_id={con_id}] move absolute position {geo['x'] + dx} {geo['y'] + dy}")


def main():
    data = load()
    proc = subprocess.Popen(["swaymsg", "-t", "subscribe", "-m", '["window"]'],
                            stdout=subprocess.PIPE, text=True)
    for line in proc.stdout:
        try:
            ev = json.loads(line)
        except ValueError:
            continue
        con = ev.get("container", {})
        app = con.get("app_id")
        if app not in APPS:
            continue
        if ev.get("change") == "new" and app in data:
            restore(con["id"], data[app])
        elif ev.get("change") == "close" and con.get("type") == "floating_con":
            r = con["rect"]
            data[app] = {"x": r["x"], "y": r["y"], "width": r["width"], "height": r["height"]}
            save(data)


if __name__ == "__main__":
    main()
