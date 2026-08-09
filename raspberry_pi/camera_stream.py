"""
SmartDose – Raspberry Pi USB Webcam MJPEG Live Stream Server
==============================================================

Camera:
    EMEET SmartCam C60E 4K USB Webcam
    /dev/video0

Protocol:
    MJPEG over HTTP

Internet access:
    Cloudflare Quick Tunnel

Backend:
    Firebase Admin SDK / Firestore

The Flutter/mobile application can:
    1. Read the device streamUrl from Firestore.
    2. Open the /stream endpoint.
    3. Receive a continuous MJPEG camera stream.

This version uses OpenCV/V4L2 instead of Picamera2 because
the project uses a USB webcam.
"""

import io
import re
import signal
import socket
import subprocess
import sys
import threading
import time
import logging

from http.server import BaseHTTPRequestHandler, HTTPServer

import cv2
import firebase_admin
from firebase_admin import credentials, firestore


# ─────────────────────────────────────────────────────────────────────────────
# CONFIG
# ─────────────────────────────────────────────────────────────────────────────

SERVICE_ACCOUNT_KEY = "service_account_key.json"

DEVICE_ID = "SMARTDOSE_DEV_001"

# USB webcam
CAMERA_DEVICE = "/dev/video0"

# Camera settings
CAPTURE_WIDTH = 1280
CAPTURE_HEIGHT = 720
FPS = 30

# MJPEG HTTP server
HTTP_PORT = 8080


# ─────────────────────────────────────────────────────────────────────────────
# LOGGING
# ─────────────────────────────────────────────────────────────────────────────

logging.basicConfig(
    level=logging.INFO,
    format="[SmartDose %(asctime)s] %(message)s",
    datefmt="%H:%M:%S",
)

log = logging.getLogger(__name__)


# ─────────────────────────────────────────────────────────────────────────────
# THREAD-SAFE FRAME BUFFER
# ─────────────────────────────────────────────────────────────────────────────

class StreamingOutput:
    """
    Stores the latest JPEG frame.

    The camera thread writes frames here.
    HTTP clients read the latest available frame.
    """

    def __init__(self):
        self.frame = None
        self._cond = threading.Condition()

    def write(self, frame: bytes):
        with self._cond:
            self.frame = frame
            self._cond.notify_all()

    def wait_for_frame(self):
        with self._cond:
            while self.frame is None:
                self._cond.wait()

            return self.frame


_output = StreamingOutput()


# ─────────────────────────────────────────────────────────────────────────────
# MJPEG HTTP SERVER
# ─────────────────────────────────────────────────────────────────────────────

_BOUNDARY = b"frame"
_BOUNDARY_HDR = b"--frame\r\n"


class MJPEGHandler(BaseHTTPRequestHandler):

    def log_message(self, fmt, *args):
        # Disable normal HTTP request logging
        pass

    def do_GET(self):

        if self.path in ("/stream", "/"):
            self._serve_stream()

        elif self.path == "/health":
            self._serve_health()

        else:
            self.send_error(404, "Not Found")

    def _serve_health(self):

        body = b'{"status":"online"}'

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-cache")
        self.end_headers()

        self.wfile.write(body)

    def _serve_stream(self):

        self.send_response(200)

        self.send_header("Age", "0")
        self.send_header("Cache-Control", "no-cache, private")
        self.send_header("Pragma", "no-cache")

        self.send_header(
            "Content-Type",
            f"multipart/x-mixed-replace; boundary={_BOUNDARY.decode()}",
        )

        self.end_headers()

        client_ip = self.client_address[0]

        log.info(f"Client connected: {client_ip}")

        try:

            while True:

                frame = _output.wait_for_frame()

                self.wfile.write(_BOUNDARY_HDR)

                self.wfile.write(
                    b"Content-Type: image/jpeg\r\n"
                )

                self.wfile.write(
                    f"Content-Length: {len(frame)}\r\n\r\n".encode()
                )

                self.wfile.write(frame)

                self.wfile.write(b"\r\n")

        except (BrokenPipeError, ConnectionResetError):

            log.info(
                f"Client disconnected: {client_ip}"
            )

        except Exception as exc:

            log.warning(
                f"Stream error: {exc}"
            )


class _ReusableServer(HTTPServer):

    allow_reuse_address = True

    daemon_threads = True


# ─────────────────────────────────────────────────────────────────────────────
# USB CAMERA
# ─────────────────────────────────────────────────────────────────────────────

_camera = None


def start_camera():
    """
    Open the EMEET USB webcam using V4L2/OpenCV.
    """

    global _camera

    log.info(
        f"Opening USB camera: {CAMERA_DEVICE}"
    )

    _camera = cv2.VideoCapture(
        CAMERA_DEVICE,
        cv2.CAP_V4L2
    )

    if not _camera.isOpened():

        raise RuntimeError(
            f"Cannot open camera {CAMERA_DEVICE}"
        )

    # Use MJPEG from the USB webcam.
    _camera.set(
        cv2.CAP_PROP_FOURCC,
        cv2.VideoWriter_fourcc(*"MJPG")
    )

    _camera.set(
        cv2.CAP_PROP_FRAME_WIDTH,
        CAPTURE_WIDTH
    )

    _camera.set(
        cv2.CAP_PROP_FRAME_HEIGHT,
        CAPTURE_HEIGHT
    )

    _camera.set(
        cv2.CAP_PROP_FPS,
        FPS
    )

    # Read actual settings reported by camera.
    actual_width = int(
        _camera.get(cv2.CAP_PROP_FRAME_WIDTH)
    )

    actual_height = int(
        _camera.get(cv2.CAP_PROP_FRAME_HEIGHT)
    )

    actual_fps = _camera.get(
        cv2.CAP_PROP_FPS
    )

    log.info(
        f"Camera opened: "
        f"{actual_width}x{actual_height} @ "
        f"{actual_fps:.1f} fps"
    )

    return _camera


def camera_loop():

    """
    Continuously capture frames from the USB webcam,
    convert them to JPEG, and place them in the shared
    streaming buffer.
    """

    global _camera

    while True:

        if _camera is None:
            time.sleep(1)
            continue

        ret, frame = _camera.read()

        if not ret:

            log.warning(
                "Could not read frame from USB camera"
            )

            time.sleep(0.1)

            continue

        # Encode frame as JPEG.
        success, encoded = cv2.imencode(
            ".jpg",
            frame,
            [
                cv2.IMWRITE_JPEG_QUALITY,
                80
            ]
        )

        if not success:

            log.warning(
                "Failed to encode camera frame"
            )

            continue

        # Convert NumPy array to bytes.
        jpeg_bytes = encoded.tobytes()

        _output.write(jpeg_bytes)


# ─────────────────────────────────────────────────────────────────────────────
# CLOUDFLARE QUICK TUNNEL
# ─────────────────────────────────────────────────────────────────────────────

def _start_cloudflare_tunnel(port: int) -> str | None:

    """
    Start:

        cloudflared tunnel --url http://localhost:<port>

    and extract the public HTTPS URL.
    """

    try:

        proc = subprocess.Popen(
            [
                "cloudflared",
                "tunnel",
                "--url",
                f"http://localhost:{port}",
                "--no-autoupdate",
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )

        url_re = re.compile(
            r"https://[a-z0-9\-]+\.trycloudflare\.com"
        )

        deadline = time.time() + 40

        for line in proc.stdout:

            line = line.rstrip()

            if line:

                log.info(
                    f"cloudflared | {line}"
                )

            match = url_re.search(line)

            if match:

                return match.group(0)

            if time.time() > deadline:

                log.error(
                    "cloudflared tunnel URL "
                    "not received within 40 seconds"
                )

                break

    except FileNotFoundError:

        log.error(
            "cloudflared not found."
        )

        log.error(
            "Run bash start_stream.sh "
            "or install cloudflared manually."
        )

    except Exception as exc:

        log.error(
            f"Cloudflare startup error: {exc}"
        )

    return None


# ─────────────────────────────────────────────────────────────────────────────
# FIREBASE
# ─────────────────────────────────────────────────────────────────────────────

_db = None


def _init_firebase():

    global _db

    cred = credentials.Certificate(
        SERVICE_ACCOUNT_KEY
    )

    firebase_admin.initialize_app(
        cred
    )

    _db = firestore.client()

    log.info(
        "Firebase Admin SDK initialised"
    )


def _device_ref():

    return (
        _db
        .collection("devices")
        .document(DEVICE_ID)
    )


def _set_online(stream_url: str | None):

    _device_ref().set(
        {
            "isOnline": stream_url is not None,

            "streamUrl": stream_url,

            "lastSeen":
                firestore.SERVER_TIMESTAMP,
        },
        merge=True,
    )


# ─────────────────────────────────────────────────────────────────────────────
# HEARTBEAT
# ─────────────────────────────────────────────────────────────────────────────

def _heartbeat_loop():

    """
    Update lastSeen every 60 seconds.
    """

    while True:

        time.sleep(60)

        try:

            _device_ref().update(
                {
                    "lastSeen":
                        firestore.SERVER_TIMESTAMP
                }
            )

        except Exception as exc:

            log.warning(
                f"Heartbeat error: {exc}"
            )


# ─────────────────────────────────────────────────────────────────────────────
# SHUTDOWN
# ─────────────────────────────────────────────────────────────────────────────

_server = None


def _shutdown(signum=None, frame=None):

    log.info(
        "Shutting down SmartDose..."
    )

    # Mark device offline.
    try:

        _set_online(None)

    except Exception:

        pass

    # Stop camera.
    global _camera

    if _camera is not None:

        try:

            _camera.release()

        except Exception:

            pass

        _camera = None

    # Stop HTTP server.
    global _server

    if _server is not None:

        try:

            _server.shutdown()

        except Exception:

            pass

    sys.exit(0)


# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────

def main():

    global _server

    signal.signal(
        signal.SIGTERM,
        _shutdown
    )

    signal.signal(
        signal.SIGINT,
        _shutdown
    )

    log.info(
        "═══════════════════════════════════"
    )

    log.info(
        "  SmartDose USB Webcam Server"
    )

    log.info(
        "═══════════════════════════════════"
    )

    # ── 1. Firebase ─────────────────────────────────────────────────────────

    _init_firebase()

    # Mark device offline until camera/stream is ready.
    _set_online(None)

    # ── 2. USB Camera ───────────────────────────────────────────────────────

    start_camera()

    log.info(
        f"Camera device: {CAMERA_DEVICE}"
    )

    # Start camera capture thread.
    threading.Thread(
        target=camera_loop,
        daemon=True
    ).start()

    # ── 3. MJPEG HTTP Server ────────────────────────────────────────────────

    _server = _ReusableServer(
        ("0.0.0.0", HTTP_PORT),
        MJPEGHandler
    )

    threading.Thread(
        target=_server.serve_forever,
        daemon=True
    ).start()

    log.info(
        f"MJPEG server → "
        f"http://localhost:{HTTP_PORT}/stream"
    )

    log.info(
        f"Health check → "
        f"http://localhost:{HTTP_PORT}/health"
    )

    # ── 4. Cloudflare Tunnel ────────────────────────────────────────────────

    log.info(
        "Starting Cloudflare tunnel "
        "(may take up to 40 seconds)..."
    )

    base_url = _start_cloudflare_tunnel(
        HTTP_PORT
    )

    if base_url:

        stream_url = (
            f"{base_url}/stream"
        )

        log.info(
            f"✅ Public stream URL: "
            f"{stream_url}"
        )

    else:

        # Fallback to local IP.
        local_ip = socket.gethostbyname(
            socket.gethostname()
        )

        stream_url = (
            f"http://{local_ip}:"
            f"{HTTP_PORT}/stream"
        )

        log.warning(
            "⚠️ Cloudflare tunnel failed."
        )

        log.warning(
            f"Local stream: {stream_url}"
        )

    # ── 5. Firebase Stream URL ──────────────────────────────────────────────

    _set_online(
        stream_url
    )

    log.info(
        f"Firestore updated → "
        f"devices/{DEVICE_ID}.streamUrl"
    )

    # ── 6. Heartbeat ────────────────────────────────────────────────────────

    threading.Thread(
        target=_heartbeat_loop,
        daemon=True
    ).start()

    # ── 7. Keep Server Running ──────────────────────────────────────────────

    log.info(
        "Streaming. Press Ctrl-C to stop."
    )

    signal.pause()


# ─────────────────────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":

    main()
