#!/usr/bin/env bash
# setup-galen-tools.sh: install and run the 2007 OpenGALEN toolset (Kermanog ROIS
# terminology server, GCE browser, GCEwork GRAIL workspace, SPET, GirC, Humpty) and,
# optionally, OpenKnoME 5.4d under Wine on Linux.
#
# Nothing is bundled here. The script downloads the public files from the OpenGALEN
# mirror (https://opengalen.eggbird.eu/sources/software.html) into a cache folder.
# Licences: the Kermanog toolset is under its own single-user evaluation licence
# (shown in OpenGALEN.txt; the bundled licence key runs until 2027-07-21) and must not
# be redistributed or put on a public network. OpenKnoME is under the topThing Open
# Source Licence plus Cincom's non-commercial VisualWorks licence. The models are under
# the GALEN Open Source Licence (gosl.html). Read them before use.
#
# Usage:
#   scripts/setup-galen-tools.sh install          # prefix + toolset (+ OpenGALEN 8 compiled model)
#   scripts/setup-galen-tools.sh rois             # start the ROIS server (TCP 3800)
#   scripts/setup-galen-tools.sh gce|gcework|spet|girc|humpty
#   scripts/setup-galen-tools.sh openknome        # OpenKnoME 5.4d (see notes in the docs: partial)
#   scripts/setup-galen-tools.sh kill
# Environment: WINEPREFIX (default ~/.cache/galen-tools/wine), GALEN_CACHE (downloads),
#              DISPLAY (an X display; e.g. `Xvfb :9 &` and DISPLAY=:9 for headless use).
set -euo pipefail

MIRROR=https://opengalen.eggbird.eu/download
CACHE=${GALEN_CACHE:-$HOME/.cache/galen-tools}
export WINEPREFIX=${WINEPREFIX:-$CACHE/wine}
export WINEARCH=win32
export WINEDEBUG=${WINEDEBUG:--all}
export WINEDLLOVERRIDES=${WINEDLLOVERRIDES:-"mscoree,mshtml,winemenubuilder.exe=d"}
ROIS_WIN='C:\Program Files\Kermanog\rois'
ROIS="$WINEPREFIX/drive_c/Program Files/Kermanog/rois"

# sha256 of the mirror files as downloaded on 2026-11-18
declare -A SHA=(
  [opengalen.exe]=5f48b207a287d6046e87872466281cc3a1b16893133a9f49edcf426a44a84fdd
  [openknome.zip]=178c5f79572fe0f667849a05397592fbf7b2a48e07b9d617c00fb05693e1f6f8
  [opengalen8-compiled.zip]=adc026328ef10f26dfede2351a8e842cc9488cf46d878603a923fffcfe23ebc2
)

need() { for c in "$@"; do command -v "$c" >/dev/null || { echo "missing: $c" >&2; exit 1; }; done; }

fetch() { # fetch NAME -> $CACHE/NAME, checked against SHA
  local f=$1; mkdir -p "$CACHE"
  [ -s "$CACHE/$f" ] || curl -fL --retry 3 -o "$CACHE/$f" "$MIRROR/$f"
  if [ -n "${SHA[$f]:-}" ]; then
    echo "${SHA[$f]}  $CACHE/$f" | sha256sum -c --quiet - || { echo "checksum changed for $f (mirror updated?)" >&2; exit 1; }
  fi
}

install_toolset() {
  need wine wineboot unzip curl sha256sum python3
  fetch opengalen.exe
  [ -f "$WINEPREFIX/system.reg" ] || { wineboot -i; wineserver -w; }
  local tmp; tmp=$(mktemp -d)
  unzip -q -o "$CACHE/opengalen.exe" -d "$tmp"   # the installer is a self-extracting zip
  # Same layout as the bundled Setup.exe (setup.ini); done by hand so no GUI clicks are needed.
  python3 - "$tmp" "$ROIS" <<'PY'
import configparser, os, shutil, sys
src, root = sys.argv[1], sys.argv[2]
c = configparser.RawConfigParser(strict=False); c.optionxform = str
c.read(os.path.join(src, 'setup.ini'))
for i in range(1, int(c['Setup']['Groups']) + 1):
    s = c[f'Install_{i}']; d = os.path.join(root, s['Directory'].replace('\\', '/'))
    os.makedirs(d, exist_ok=True)
    for k in range(1, int(s['Files']) + 1):
        f = s.get(f'File_{k}')
        if f: shutil.copy(os.path.join(src, f), d)
PY
  rm -rf "$tmp"
  # projects.xml is not shipped; without it ROIS answers getProjects with an empty list.
  # Element names come from ROIS.exe and OpenKnoME's getRoisDirectoryFromXML:.
  local p
  { echo '<?xml version="1.0"?>'; echo '<ROIS>'
    for p in Default openknome54d; do cat <<XML
  <Project>
    <Name>$p</Name>
    <Home>$ROIS_WIN</Home>
    <Models>$ROIS_WIN\\models</Models>
    <Archives>$ROIS_WIN\\archives</Archives>
    <System>$ROIS_WIN\\system</System>
  </Project>
XML
    done; echo '</ROIS>'; } > "$ROIS/projects.xml"
  wine reg add 'HKLM\Software\Kermanog\ROIS' /v Home /d "$ROIS_WIN\\" /f >/dev/null
  wine reg add 'HKLM\Software\Kermanog\ROIS' /v Version /d 6.23.00 /f >/dev/null
  wine reg add 'HKLM\Software\Kermanog\ClaW\GCE' /v Home /d "$ROIS_WIN\\claw\\" /f >/dev/null
  # One Wine virtual desktop, so the ROIS tray icon and dialogs are reachable without a window manager.
  wine reg add 'HKCU\Software\Wine\Explorer' /v Desktop /d Default /f >/dev/null
  wine reg add 'HKCU\Software\Wine\Explorer\Desktops' /v Default /d 1260x880 /f >/dev/null
  # The compiled OpenGALEN 8 model (68 MB .gra) next to the small ear/evaluation models.
  fetch opengalen8-compiled.zip
  unzip -q -o -j "$CACHE/opengalen8-compiled.zip" 'OpenGALEN8/Compiled_Model/OpenGALEN8_FULL.*' -d "$ROIS/models"
  wineserver -w
  echo "Installed OpenGALEN toolset in $ROIS"
}

install_openknome() {
  fetch openknome.zip
  unzip -q -o "$CACHE/openknome.zip" -d "$WINEPREFIX/drive_c/"
  echo "Installed OpenKnoME in $WINEPREFIX/drive_c/openknome"
}

start_bg() { (cd "$1" && setsid nohup wine "$2" "${@:3}" >"$CACHE/$2.log" 2>&1 &); }

ensure_display() { # headless: start our own Xvfb when no DISPLAY is set
  if [ -z "${DISPLAY:-}" ]; then
    need Xvfb; export DISPLAY=:77
    xdpyinfo >/dev/null 2>&1 || { setsid -f Xvfb :77 -screen 0 1280x900x24 -noreset >"$CACHE/xvfb.log" 2>&1; sleep 2; }
    echo "Using headless DISPLAY=:77 (screenshot: import -display :77 -window root shot.png)"
  fi
}

port_up() { (exec 3<>/dev/tcp/127.0.0.1/3800) 2>/dev/null; }

start_rois() { # ROIS quits when its last client disconnects, so keep one idle session open
  ensure_display
  port_up && return 0
  while pgrep -f ROIS.exe >/dev/null; do sleep 1; done
  start_bg "$ROIS" ROIS.exe
  for _ in $(seq 30); do port_up && break; sleep 1; done
  port_up || { echo "ROIS did not start; see $CACHE/ROIS.exe.log" >&2; exit 1; }
  setsid -f python3 -c 'import socket,time
s=socket.create_connection(("127.0.0.1",3800))
s.sendall(b"<ROIS><Client>keepalive</Client><User>keepalive</User><NameSpace>INTERNAL</NameSpace></ROIS>"+b"\0"*4)
while True: time.sleep(3600)' >/dev/null 2>&1
  echo "ROIS listening on TCP 3800 (plus a keep-alive session; 'kill' stops both)"
}

cmd=${1:-help}
case $cmd in
  install) install_toolset; install_openknome ;;
  rois) start_rois ;;
  gce|gcework|spet|girc|humpty)
    start_rois
    exe=$(case $cmd in gce) echo GCE.exe;; gcework) echo GCEwork.exe;; spet) echo SPET.exe;; girc) echo GirC.exe;; humpty) echo HUMPTY.EXE;; esac)
    start_bg "$ROIS/claw" "$exe"
    echo "In the login box: server 'localhost', Connect, any user name, project 'Default', Ok." ;;
  openknome)
    start_rois
    start_bg "$WINEPREFIX/drive_c/openknome" visual.exe openknome54d.im ;;
  kill) pkill -f 'Client>keepalive' || true; wineserver -k || true ;;
  *) sed -n '2,25p' "$0"; exit 2 ;;
esac
