---
layout: default
title: "Clinergy: extractor and running the demo in Wine"
permalink: /docs/clinergy/
---

# Clinergy: extractor and running the demo in Wine

Clinergy was a structured data entry system for primary care built on the PEN&PAD approach, "built on top of a live GALEN terminology server delivering an adaptation of a GALEN Common Reference Model" ([OpenGALEN software page](https://opengalen.eggbird.eu/sources/software.html)). Alan Rector demonstrates it in [interview part 1](/interviews/alan-rector-part-1/#t=685), and the [thumb pain walkthrough](/docs/clinergy-thumb-pain-demo/) goes through that demo screen by screen. This page covers the YAML extractor and how to run the 1998 Windows demo under Wine on Linux. The [front page](/#clinergy) has a short summary.

## Demo download

[ClinergyDemo.zip](https://opengalen.eggbird.eu/download/ClinergyDemo.zip) (6 MB, a 1998 Windows installer) is on the OpenGALEN mirror. There is also a [copy archived from opengalen.org](https://web.archive.org/web/20070818150258/http://www.opengalen.org/download/clinergydemo.zip). The demo is © 1997-8 Semantic Technologies Ltd / Victoria University of Manchester, All Rights Reserved.

## Extractor

[clinergy-extractor](https://github.com/erik-sundvalls-bots/clinergy-extractor) turns your copy of the zip into human-readable YAML: one file per data-entry form, plus concepts, examinations, summary-sentence rules and body maps. It also helps map Clinergy names to OpenGALEN 8: exact matches first, then a review worklist for a person or an AI agent, using a small OpenGALEN MCP server.

It also exports the body-map pictures, icons, cursors and bitmaps to `images/` (BMP/ICO/CUR converted to PNG; ICO/CUR originals kept; WMF kept as `.wmf`), with an `images.yaml` index, and writes body-map hotspot coordinates in `bodymap.yaml`.

It needs [Deno](https://deno.com/), Wine and the 32-bit MinGW compiler (details in the extractor [README](https://github.com/erik-sundvalls-bots/clinergy-extractor)):

```sh
git clone https://github.com/erik-sundvalls-bots/clinergy-extractor && cd clinergy-extractor
deno task extract ClinergyDemo.zip out/
```

The output is a private study copy. Please don't publish it. The repository contains only the extractor code, not the demo or any extracted Clinergy content.

## Running Clinergy in Wine on Linux

The demo itself runs under Wine 10 (tested on Debian). The extractor repo has a script that does all of this:

* Use a 32-bit prefix (`WINEARCH=win32`) set to Windows XP.
* Skip the 16-bit `SETUP.EXE` and unpack the installer payload yourself. The script uses the extractor's unpacker to put the programs in `C:\Clinergy\Programs`, the model, INI and bitmap files in `C:\Clinergy\Compdata`, and `Penpad.ini` in `C:\windows`.
* Use the bundled `Mfc42.dll`, but keep Wine's own `msvcrt` instead of the 1997 `Msvcrt.dll`: `WINEDLLOVERRIDES="mscoree,mshtml,winemenubuilder.exe=d;mfc42,mfc42u=n;msvcrt=b"`.
* Start `penpad.exe` from `C:\Clinergy\Programs`, then load the model by the name `model`.
* The menu bar does not appear under Wine. The script sends the menu commands as `WM_COMMAND` messages instead: 32771 = Load model, 32772 = Symptom Selector.
* Not working: the VB, Gen and Win host demos. They need the `PENPAD.CONNECT` OLE server, the VB4 runtime and a `penpad.mdb` patient database that is not in the zip.

```sh
deno run -A clinergy-wine.ts install ClinergyDemo.zip   # in the clinergy-extractor folder
deno run -A clinergy-wine.ts demo                       # Pen&Pad with the model loaded and the Symptom Selector open
```
