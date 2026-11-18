#!/usr/bin/env bash
# setup-wine-clinergy.sh: install and run the 1998 Clinergy (PEN&PAD) demo and its three
# host demos (VB, Win, Gen) under Wine on Linux.
#
# Nothing from Clinergy is bundled here. The demo is (c) 1997-8 Semantic Technologies Ltd /
# Victoria University of Manchester, All Rights Reserved; the script downloads
# ClinergyDemo.zip from the OpenGALEN mirror into a cache folder and unpacks it with
# clinergy-extractor (https://github.com/erik-sundvalls-bots/clinergy-extractor).
# On top of that install it adds what the host demos need under Wine and builds ppmenu,
# a stand-in for Pen&Pad's menu bar (source: scripts/clinergy/ppmenu.c).
#
# Usage:
#   scripts/setup-wine-clinergy.sh install     # prefix + demo + VB runtime/OCX registration + ppmenu
#   scripts/setup-wine-clinergy.sh penpad      # Pen&Pad with the ppmenu menu bar
#   scripts/setup-wine-clinergy.sh demo        # clinergy-wine.ts demo: model loaded, Symptom Selector open
#   scripts/setup-wine-clinergy.sh vbdemo|windemo|gendemo   # host demos (they start Pen&Pad over OLE)
#   scripts/setup-wine-clinergy.sh kill
#   scripts/setup-wine-clinergy.sh fetch       # only download and verify ClinergyDemo.zip
# Needs: wine with 32-bit support (Debian: dpkg --add-architecture i386; apt install wine wine32:i386),
#        i686-w64-mingw32-gcc (gcc-mingw-w64-i686), deno, git, curl, unzip, sha256sum.
# Download source: SOURCE=mirror (default; opengalen.eggbird.eu), SOURCE=archive (Internet
#   Archive Wayback capture of the original opengalen.org file, byte-identical), or SOURCE=auto
#   (mirror first, archive if that fails). Also accepted as --source=... first argument.
# Environment: WINEPREFIX (default ~/.cache/clinergy-extractor/wine-clinergy), CLINERGY_CACHE,
#              CLINERGY_EXTRACTOR (an existing checkout), DISPLAY (headless: a private Xvfb :78 is started).
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
case ${1:-} in --source=*) SOURCE=${1#--source=}; shift ;; esac
SOURCE=${SOURCE:-mirror}
case $SOURCE in mirror|archive|auto) ;; *) echo "SOURCE must be mirror, archive or auto" >&2; exit 2 ;; esac
ZIP_URL=https://opengalen.eggbird.eu/download/ClinergyDemo.zip
# Internet Archive capture of www.opengalen.org; checked 2026-11-18 to match ZIP_SHA exactly.
ZIP_ARCHIVE=https://web.archive.org/web/20070818150258id_/http://www.opengalen.org/download/clinergydemo.zip
ZIP_SHA=f138c38b24de630ce0c89bc8018dbc68fc2b17e040235c9c01e10761d8114270   # as downloaded 2026-11-18
CACHE=${CLINERGY_CACHE:-$HOME/.cache/clinergy-extractor}
EXTRACTOR=${CLINERGY_EXTRACTOR:-$CACHE/clinergy-extractor}
export WINEPREFIX=${WINEPREFIX:-$CACHE/wine-clinergy}
export WINEARCH=win32
export WINEDEBUG=${WINEDEBUG:--all}
export WINEDLLOVERRIDES="mscoree,mshtml,winemenubuilder.exe=d;mfc42,mfc42u=n;msvcrt=b"
C="$WINEPREFIX/drive_c"
PROG="$C/Clinergy/Programs"

need() { for c in "$@"; do command -v "$c" >/dev/null || { echo "missing: $c" >&2; exit 1; }; done; }

ensure_display() {
  if [ -z "${DISPLAY:-}" ]; then
    need Xvfb; export DISPLAY=:78
    xdpyinfo >/dev/null 2>&1 || { setsid -f Xvfb :78 -screen 0 1280x900x24 -noreset >"$CACHE/xvfb.log" 2>&1; sleep 2; }
    echo "Using headless DISPLAY=:78 (screenshot: import -display :78 -window root shot.png)"
  fi
}

get() { # get URL -> $CACHE/ClinergyDemo.zip, checked
  local zip="$CACHE/ClinergyDemo.zip"
  echo "Downloading ClinergyDemo.zip from $1" >&2
  curl -fL --retry 3 -o "$zip.part" "$1" || return 1
  echo "$ZIP_SHA  $zip.part" | sha256sum -c --quiet - >/dev/null 2>&1 || { echo "checksum mismatch from $1" >&2; rm -f "$zip.part"; return 1; }
  mv "$zip.part" "$zip"
}

fetch_zip() {
  need curl sha256sum; mkdir -p "$CACHE"
  local zip="$CACHE/ClinergyDemo.zip"
  if [ -s "$zip" ] && echo "$ZIP_SHA  $zip" | sha256sum -c --quiet - >/dev/null 2>&1; then return 0; fi
  case $SOURCE in
    mirror)  get "$ZIP_URL" ;;
    archive) get "$ZIP_ARCHIVE" ;;
    auto)    get "$ZIP_URL" || { echo "mirror failed, trying the Internet Archive" >&2; get "$ZIP_ARCHIVE"; } ;;
  esac || { echo "could not get a verified ClinergyDemo.zip" >&2; exit 1; }
}

install_all() {
  need wine wineserver i686-w64-mingw32-gcc deno git curl unzip sha256sum
  mkdir -p "$CACHE"
  fetch_zip
  local zip="$CACHE/ClinergyDemo.zip"
  [ -d "$EXTRACTOR/.git" ] || git clone --depth 1 https://github.com/erik-sundvalls-bots/clinergy-extractor "$EXTRACTOR"
  ensure_display
  # 1. The documented install: 32-bit XP prefix, installer payload unpacked to C:\Clinergy.
  (cd "$EXTRACTOR" && deno run -A clinergy-wine.ts install "$zip" --prefix "$WINEPREFIX")
  # 2. One Wine virtual desktop: without a window manager the host demos' and ppmenu's
  #    popup menus and title bars do not work reliably.
  wine reg add 'HKCU\Software\Wine\Explorer' /v Desktop /d Default /f >/dev/null
  wine reg add 'HKCU\Software\Wine\Explorer\Desktops' /v Default /d 1260x880 /f >/dev/null
  # 3. VB4 runtime and controls for the host demos. The 16-bit installer would have put these
  #    in the system folder and registered them. ven2232.olb is looked up as
  #    C:\WINDOWS\SYSTEM\ven2232.olb (path recorded in the VB programs); without it Win Demo
  #    stops with "Run-time error 48: Error in loading DLL" when a patient is selected.
  local sys="$C/windows/system32" f
  for f in VB40032.DLL MFC40.DLL MSVCRT40.DLL GRDKRN32.DLL gswdll32.dll msvcrt20.dll ven2232.olb dao2532.tlb "$PROG"/*.OCX; do
    cp -f "$PROG/$(basename "$f")" "$sys/"
  done
  mkdir -p "$C/windows/system"; cp -f "$PROG/ven2232.olb" "$C/windows/system/"
  for f in "$PROG"/*.OCX; do wine regsvr32 /s "C:\\windows\\system32\\$(basename "$f")" || echo "regsvr32 failed: $(basename "$f")"; done
  # 4. Register VBDemo's own OLE class (VBPenPadHost.VBHostConnector), which Pen&Pad calls back
  #    when a session is accepted, and Pen&Pad's own PENPAD.CONNECT server (without it the
  #    host demos stop with "Run-time error 429: OLE Automation server can't create object").
  #    penpad.exe /regserver registers but does not exit, so wait for the key and stop it.
  (cd "$C/Clinergy/VB Demo" && wine VBDemo.exe /regserver) || true
  (cd "$PROG" && setsid nohup wine penpad.exe /regserver >"$CACHE/regserver.log" 2>&1 &)
  for _ in $(seq 60); do wine reg query 'HKCR\PENPAD.CONNECT' >/dev/null 2>&1 && break; sleep 1; done
  wine reg query 'HKCR\PENPAD.CONNECT' >/dev/null 2>&1 || echo "warning: PENPAD.CONNECT not registered" >&2
  wineserver -k || true; sleep 1
  # 5. ppmenu, the stand-in menu bar.
  i686-w64-mingw32-gcc -O1 -mwindows -o "$PROG/ppmenu.exe" "$HERE/clinergy/ppmenu.c"
  wineserver -w
  echo "Installed Clinergy in $C/Clinergy"
}

run_in() { # run_in DIR EXE [ARGS]
  ensure_display
  (cd "$1" && setsid nohup wine "$2" "${@:3}" >"$CACHE/$2.log" 2>&1 &)
}

case ${1:-help} in
  install) install_all ;;
  fetch)   fetch_zip; echo "ClinergyDemo.zip verified in $CACHE (source: $SOURCE)" ;;
  penpad)  run_in "$PROG" penpad.exe; sleep 8; run_in "$PROG" ppmenu.exe
           echo "Pen&Pad started. Use the ppmenu bar at the bottom: Model > Load model (name: model), then DEM > Symptom etc." ;;
  demo)    ensure_display; (cd "$EXTRACTOR" && deno run -A clinergy-wine.ts demo --prefix "$WINEPREFIX") ;;
  vbdemo)  run_in "$C/Clinergy/VB Demo" VBDemo.exe ;;
  windemo) run_in "$C/Clinergy/Win Demo" windemo.exe; echo "Log in with any user name and no password." ;;
  gendemo) run_in "$C/Clinergy/Gen Demo" gendemo.exe ;;
  kill)    wineserver -k || true ;;
  *) sed -n '2,26p' "$0" ;;
esac
