#!/usr/bin/env python3
"""Screen recording through OBS, for the quick access panel.

  obs-record.py toggle   start / stop recording
  obs-record.py status   print "true" while recording, else "false" (swaync toggle state)

Talks to OBS's built-in websocket server (v5 protocol, localhost:4455, password from OBS's own
plugin_config). If OBS is not running, it is started in the tray with --startrecording and quit
again when the recording is stopped; an OBS that was already open (screencam, or opened by hand)
is left running. What gets recorded is OBS's current scene, saved where OBS is set to save.
"""
import base64, hashlib, json, os, socket, struct, subprocess, sys, time

CONF = os.path.expanduser("~/.config/obs-studio/plugin_config/obs-websocket/config.json")
STATE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "obs-record-launched")
SIGNAL = 12   # waybar signal of custom/quick


class WS:
    """Just enough of a websocket client for OBS: text frames, client-side masking."""

    def __init__(self, port):
        self.s = socket.create_connection(("127.0.0.1", port), timeout=3)
        key = base64.b64encode(os.urandom(16)).decode()
        self.s.sendall((f"GET / HTTP/1.1\r\nHost: 127.0.0.1:{port}\r\nUpgrade: websocket\r\n"
                        f"Connection: Upgrade\r\nSec-WebSocket-Key: {key}\r\n"
                        "Sec-WebSocket-Protocol: obswebsocket.json\r\n"
                        "Sec-WebSocket-Version: 13\r\n\r\n").encode())
        head = b""
        while b"\r\n\r\n" not in head:
            chunk = self.s.recv(1024)
            if not chunk:
                raise ConnectionError("handshake closed")
            head += chunk
        if b" 101 " not in head.split(b"\r\n", 1)[0]:
            raise ConnectionError("handshake refused")
        self.buf = head.split(b"\r\n\r\n", 1)[1]

    def _read(self, n):
        while len(self.buf) < n:
            chunk = self.s.recv(65536)
            if not chunk:
                raise ConnectionError("closed")
            self.buf += chunk
        out, self.buf = self.buf[:n], self.buf[n:]
        return out

    def send(self, obj):
        data = json.dumps(obj).encode()
        mask = os.urandom(4)
        n = len(data)
        head = bytes([0x81]) + (bytes([0x80 | n]) if n < 126 else
                                bytes([0x80 | 126]) + struct.pack(">H", n) if n < 65536 else
                                bytes([0x80 | 127]) + struct.pack(">Q", n))
        self.s.sendall(head + mask + bytes(b ^ mask[i % 4] for i, b in enumerate(data)))

    def recv(self):
        while True:
            b1, b2 = self._read(2)
            n = b2 & 0x7F
            if n == 126:
                n = struct.unpack(">H", self._read(2))[0]
            elif n == 127:
                n = struct.unpack(">Q", self._read(8))[0]
            payload = self._read(n)
            op = b1 & 0x0F
            if op == 0x1:
                return json.loads(payload)
            if op == 0x8:
                raise ConnectionError("closed by OBS")
            # ping / pong / binary: ignore


def connect():
    with open(CONF) as f:
        conf = json.load(f)
    ws = WS(conf.get("server_port", 4455))
    hello = ws.recv()["d"]
    ident = {"rpcVersion": 1, "eventSubscriptions": 0}
    auth = hello.get("authentication")
    if auth:
        secret = base64.b64encode(hashlib.sha256(
            (conf["server_password"] + auth["salt"]).encode()).digest()).decode()
        ident["authentication"] = base64.b64encode(hashlib.sha256(
            (secret + auth["challenge"]).encode()).digest()).decode()
    ws.send({"op": 1, "d": ident})
    if ws.recv().get("op") != 2:
        raise ConnectionError("not identified")
    return ws


def request(ws, kind):
    ws.send({"op": 6, "d": {"requestType": kind, "requestId": kind}})
    while True:
        msg = ws.recv()
        if msg.get("op") == 7 and msg["d"].get("requestId") == kind:
            return msg["d"]


def obs_running():
    return subprocess.run(["pgrep", "-x", "obs"], capture_output=True).returncode == 0


def notify(text):
    subprocess.run(["notify-send", "-a", "obs", "Screen recording", text])


def refresh_bar():
    subprocess.run(["pkill", f"-RTMIN+{SIGNAL}", "-x", "waybar"])


def recording():
    if not obs_running():
        return False
    try:
        return bool(request(connect(), "GetRecordStatus").get("responseData", {}).get("outputActive"))
    except (OSError, ConnectionError, ValueError, KeyError):
        return False


def toggle():
    if not obs_running():
        open(STATE, "w").close()
        subprocess.Popen(["obs", "--startrecording", "--minimize-to-tray", "--disable-shutdown-check"],
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
        notify("Recording started")
        # the bar's REC mark follows once OBS is up
        for _ in range(20):
            time.sleep(0.5)
            if recording():
                break
        refresh_bar()
        return

    try:
        ws = connect()
    except (OSError, ConnectionError, ValueError, KeyError):
        notify("OBS is running but its websocket server does not answer "
               "(Tools → WebSocket Server Settings)")
        return

    if request(ws, "GetRecordStatus").get("responseData", {}).get("outputActive"):
        path = request(ws, "StopRecord").get("responseData", {}).get("outputPath", "")
        notify(f"Saved {path}" if path else "Recording stopped")
        if os.path.exists(STATE):           # OBS was started for this recording: quit it again
            os.remove(STATE)
            for _ in range(20):             # let OBS finish writing the file first
                if not request(ws, "GetRecordStatus").get("responseData", {}).get("outputActive"):
                    break
                time.sleep(0.25)
            subprocess.run(["pkill", "-x", "obs"])
    else:
        request(ws, "StartRecord")
        notify("Recording started")
    refresh_bar()


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "toggle"
    if cmd == "status":
        print("true" if recording() else "false")
    else:
        toggle()
