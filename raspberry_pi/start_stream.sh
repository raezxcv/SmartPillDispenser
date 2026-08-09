#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
#  SmartDose – Raspberry Pi Stream Startup Script
#  Installs cloudflared (if missing), Python deps, then starts streaming.
#
#  Usage:
#    chmod +x start_stream.sh
#    bash start_stream.sh
#
#  To auto-start on boot, add to /etc/rc.local (before exit 0):
#    /home/pi/SmartDose/raspberry_pi/start_stream.sh &
# ═══════════════════════════════════════════════════════════════════════
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLOUDFLARED="/usr/local/bin/cloudflared"

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║   SmartDose CCTV Stream Launcher     ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# ── 1. Install cloudflared if not present ───────────────────────────────
if ! command -v cloudflared &>/dev/null; then
    echo "[1/3] Installing cloudflared…"
    ARCH=$(uname -m)
    case "$ARCH" in
        aarch64) BIN="cloudflared-linux-arm64" ;;
        armv7l)  BIN="cloudflared-linux-arm"   ;;
        x86_64)  BIN="cloudflared-linux-amd64" ;;
        *)
            echo "ERROR: Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac
    curl -fsSL \
        "https://github.com/cloudflare/cloudflared/releases/latest/download/${BIN}" \
        -o "$CLOUDFLARED"
    chmod +x "$CLOUDFLARED"
    echo "  cloudflared installed at $CLOUDFLARED"
else
    echo "[1/3] cloudflared already installed ✓"
fi

# ── 2. Install Python dependencies ─────────────────────────────────────
echo "[2/3] Checking Python dependencies…"
pip3 install --quiet --break-system-packages firebase-admin picamera2 2>/dev/null || \
pip3 install --quiet firebase-admin picamera2 2>/dev/null || true
echo "  Python deps ready ✓"

# ── 3. Start the stream server ──────────────────────────────────────────
echo "[3/3] Starting SmartDose stream server…"
echo ""
cd "$SCRIPT_DIR"
exec python3 camera_stream.py
