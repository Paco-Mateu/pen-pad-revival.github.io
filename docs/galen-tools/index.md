---
layout: default
title: "OpenGALEN tools (ClaW/ROIS, GCE, OpenKnoME) on Linux"
permalink: /docs/galen-tools/
---

# OpenGALEN tools (ClaW/ROIS, GCE, OpenKnoME) on Linux

These are the GALEN terminology tools used to build and browse the GALEN Common Reference Model, and the server Clinergy was built on. This page covers where to get them, how to run them under Wine on Linux, what works so far, and what the running programs show about the design. Everything was tested on 2026-11-18 with Wine 10.0 on Debian 13. The [Clinergy page](/docs/clinergy/) covers the Clinergy demo itself.

## Where the tools are

All of them are on Egbert's OpenGALEN mirror, on the [software page](https://opengalen.eggbird.eu/sources/software.html):

| File | What it is | Licence |
|---|---|---|
| [`opengalen.exe`](https://opengalen.eggbird.eu/download/opengalen.exe) | Kermanog OpenGALEN toolset, a self-extracting zip: the **ROIS** terminology server 6.23.00 (`ROIS.exe`, the ClaW classifier), **GCE** (GALEN Concept Explorer, the browser), **GCEwork** (the GRAIL workspace: edit, syntax check and compile `.grl`), SPET, GirC and HUMPTY, the `.chm` help files, small example models (`ear`, `evaluation`), and the sources `Ear.grl` and the language `.grm`/`.mif` files | Kermanog single-user evaluation licence (`OpenGALEN.txt`). No redistribution, no use on a public network, no reverse-engineering. The bundled licence key (`ROIS.lic`, licence holder Stichting OpenGALEN) runs until 2027-07-21 |
| [`openknome.zip`](https://opengalen.eggbird.eu/download/openknome.zip) | **OpenKnoME 5.4d** (topThing), a Smalltalk GRAIL modelling environment on Cincom VisualWorks: `visual.exe`, the image `openknome54d.im`, `models/opengalen5.gra`, `system/knop.rvm` and `mostspecific.rvm`, the GRAIL Tutorial v3 and the KnoME manual (PDF) | topThing Open Source Licence plus Cincom's non-commercial VisualWorks licence |
| `GROWL-20091101.zip` | GROWL, the GRAIL-to-OWL patch for OpenKnoME (linked from the same page) | as listed there |
| `opengalen8-compiled.zip` | The compiled OpenGALEN 8 model, including `OpenGALEN8_FULL.gra`/`.sem` (about 68 MB), which ROIS loads | GALEN Open Source Licence (GOSL) |

The site's scripts download these files and check sha256 values. No GALEN or Kermanog binaries are kept in this repository.

### Internet Archive copies

The original opengalen.org download folder was captured by the Internet Archive's Wayback Machine (the frozen site is at [web.archive.org/web/20220308122743/https://opengalen.org/](https://web.archive.org/web/20220308122743/https://opengalen.org/)). On 2026-11-18 each file the scripts use was downloaded from its raw capture (`id_` URL) and compared with the mirror copy:

| File | Mirror | Internet Archive capture | sha256 identical |
|---|---|---|---|
| `opengalen.exe` | [mirror](https://opengalen.eggbird.eu/download/opengalen.exe) | [2016-07-12 capture](https://web.archive.org/web/20160712010405id_/http://www.opengalen.org/download/opengalen.exe) | Yes (`5f48b207…`) |
| `openknome.zip` | [mirror](https://opengalen.eggbird.eu/download/openknome.zip) | [2007-08-18 capture](https://web.archive.org/web/20070818150120id_/http://www.opengalen.org/download/openknome.zip) | Yes (`178c5f79…`) |
| `opengalen8-compiled.zip` | [mirror](https://opengalen.eggbird.eu/download/opengalen8-compiled.zip) | [2011-07-16 capture](https://web.archive.org/web/20110716101016id_/http://www.opengalen.org/download/opengalen8-compiled.zip) | Yes (`adc02632…`) |
| `ClinergyDemo.zip` | [mirror](https://opengalen.eggbird.eu/download/ClinergyDemo.zip) | [2007-08-18 capture](https://web.archive.org/web/20070818150258id_/http://www.opengalen.org/download/clinergydemo.zip) (lower-case name) | Yes (`f138c38b…`) |
| `OG8-ReadmeFirst.pdf` (not used by the scripts) | mirror | [2022-01-19 capture](https://web.archive.org/web/20220119162518id_/https://www.opengalen.org/download/OG8-ReadmeFirst.pdf) | Yes (`a358c485…`) |
| `GROWL-20091101.zip` (not used by the scripts) | mirror | none found: the CDX API has no capture under opengalen.org or the mirror, and the 2022 capture of `software.html` links it but the file returns 404 | mirror only |

A search of archive.org items (advancedsearch for opengalen, galen, clinergy, openknome) found no uploaded items with these files. Nothing else is downloaded: the VB4 runtime, OCX controls and `ven2232.olb` for the Clinergy host demos all come out of `ClinergyDemo.zip`. clinergy-extractor is cloned from GitHub.

Both scripts take a download source, as an environment variable or a first argument, and use the same checksum check for every source:

```sh
scripts/setup-galen-tools.sh install                  # default: SOURCE=mirror
SOURCE=archive scripts/setup-galen-tools.sh install   # Internet Archive captures only
scripts/setup-galen-tools.sh --source=auto install    # mirror first, Internet Archive if the download fails or does not match
scripts/setup-galen-tools.sh fetch                    # only download and verify
```

## Install and run

[`scripts/setup-galen-tools.sh`](https://github.com/pen-pad-revival/pen-pad-revival.github.io/blob/main/scripts/setup-galen-tools.sh) needs 32-bit Wine (on Debian: `dpkg --add-architecture i386` and `apt install wine wine32:i386`), plus curl, unzip and python3.

```sh
scripts/setup-galen-tools.sh install     # prefix, toolset, OpenGALEN 8 model, OpenKnoME (about 10 s after downloads)
scripts/setup-galen-tools.sh gce         # starts ROIS, then GCE
scripts/setup-galen-tools.sh gcework     # or spet, girc, humpty, openknome
scripts/setup-galen-tools.sh kill
```

Add `SOURCE=archive` or `--source=auto` to download from the Internet Archive instead (see [Internet Archive copies](#internet-archive-copies)).

In the GCE login box, use server `localhost`, Connect, any user name, project `Default`, then Ok. Model > Open `OpenGALEN8_FULL` loads the full model.

The script does the steps the GUI `Setup.exe` would do, without clicks:

* It copies the files into `C:\Program Files\Kermanog\rois` following `setup.ini`.
* It sets the `Home`/`Version` registry keys for ROIS and ClaW\GCE.
* It writes a **`projects.xml`**. This file is not shipped, and without it ROIS answers with an empty project list, so GCE cannot get past login. The element names `Project`, `Name`, `Home`, `Models`, `Archives` and `System` come from strings in `ROIS.exe` and from OpenKnoME's `getRoisDirectoryFromXML:`.
* It turns on a Wine virtual desktop, so the ROIS tray icon and dialogs work without a window manager.
* It keeps one idle client session open to ROIS (the `keepalive` client), because **ROIS exits when its last client disconnects**.

## What works (2026-11-18)

| Tool | Status |
|---|---|
| ROIS server | Runs and listens on TCP 3800. Loads `OpenGALEN8_FULL` |
| GCE | Connects, opens OpenGALEN 8, finds and browses concepts. For example, Pollux shows its supers (Finger, IntegumentaryStructure, BoneTissueStructure) and its links |
| Scripted queries | `scripts/rois_client.py`, `rois_dump_hierarchy.py` and `rois_which.py` (see below) |
| GCEwork | Opens and compiles `Ear.grl` (about 1.6 s). Compiling into the existing `ear.gra` reports many "Model not present in meta" errors (ClaW `addReference` -71) and ends with a closeModel error dialog. Compiling into a fresh model has not been worked out |
| OpenKnoME 5.4d | Starts and finds ROIS (it wants project `openknome54d`, which the script adds). Then it stops with "Error -1 ROIS cannot find needed system files ... KNOP.RVM and MOSTSPEC.RVM". Copying its `.rvm` files into ROIS's `system` folder did not help. OpenKnoME 5.4 ships client DLLs for ROIS 4 and 5 (`Client32-ROIS4/5.dll`), so it probably expects an older ROIS than 6.23 (not confirmed) |
| SPET, GirC, HUMPTY | Installed, not tested |

## Querying ROIS from scripts

```sh
scripts/setup-galen-tools.sh rois
python3 scripts/rois_dump_hierarchy.py OpenGALEN8_FULL og8_hierarchy.tsv    # about 15 s
python3 scripts/rois_which.py OpenGALEN8_FULL InflammatoryLesion hasLocation Pericardium
```

The hierarchy dump walks `Grail.subs` from `TopCategory`. For OpenGALEN 8 it gives 32,199 child–parent edges over 21,238 nodes.

`rois_which.py` asks ROIS to classify a composite concept on the fly:

* `(InflammatoryLesion which hasLocation Pericardium)` gets the supers `(PathologicalBodyStructure which involves Pericardium)`, `Serositis`, `InflammationOfBodyStructure` and `InflammatoryHeartDisease`.
* `(Pain which hasLocation Pollux)` gets `Pain`, `SymptomOfArmOrLeg` and `(Process which < involves BodyPart >)`.

Result codes seen: -150 = unknown name, -201 = not sanctioned, -153 = already exists.

Compared with the OWL dump `OpenGALEN8_WithPropertyChains_CRM+Diseases+SurgicalProcedures+DrugOntology.dump`:

* The OWL dump has 122,539 names and ROIS has 21,230. They share 18,657.
* For 11,747 of the shared names, both give exactly the same parent sets.
* 154 concepts have no parent in the OWL dump but do have parents in ROIS, for example `InvestigationResult`, `AbnormalObservation`, `Icterus` and `AdrenalDisease`.
* 2,573 names exist only in ROIS, for example `AbdominalFistula` (parent `ComponentOfAbdomen`) and `AbdominalExamination`.

## Using the running suite to design modern web tools

Only things observed in the running programs or read from their files are listed here.

**The ROIS wire protocol** (seen with tcpdump between GCE and ROIS, used only to talk to the local server).

* TCP port 3800. Each message is one XML document `<ROIS>…</ROIS>` followed by four NUL bytes. Everything happens in one persistent session.
* Session start: `<ROIS><Client>GCE</Client><User>erik</User><NameSpace>INTERNAL</NameSpace></ROIS>` → `OK`, then `<ROIS><Project>Default</Project></ROIS>` → `OK`.
* Queries have the form `<ROIS><Query module="…" task="…">…</Query></ROIS>`. Calls seen or used:
  * `System`: `openModel` (`.sem`), `openSub` (`.gra`), `findNode`, `enumModels`, `enumRVMs`, `enumTasks`
  * `Grail`: `subs`, `supers`, `which`, `whichG`, `criteria`, `extrinsic`
* Answers carry `<Model id=…>` and `<Node id=… flags=…>name</Node>` elements.
* `enumTasks` lists the server modules: ClaM, ClaW, ClawTools, Comparator, DataForm, Filter, GQL, Grail, Perspective, Sanity, Spet*, TopicForm, Constituents, Features, Frames, Generate, Generic, GrailExtension, Lexicon, Normalizer, Segments, Semantics, Syntax, Lock, NameSpace, Property, System, Tokens, Viewer.
* So the classifier is a service, and a web front end could sit on a thin HTTP-to-ROIS bridge while the original server keeps doing the classification.
* The GRAIL compiler runs in the client (GCEwork). It builds a model through server calls such as `newSub`, `addSuper`, `newAttribute` and `triple`, and classifies through `which`/`whichG`.

**Files and data formats.**

* `.sem` + `.gra` hold a compiled model, opened as a pair: `openModel` for the `.sem`, then `openSub` for the `.gra`.
* `.grl` is GRAIL source.
* `.grm`/`.mif` are language (linguistic) sources.
* `projects.xml` maps project names to model, archive and system folders.
* `.rvm` files are system files that OpenKnoME needs on the server.
* The Clinergy model is in `C:\Clinergy\Compdata\archive\model.*`.
* `Options.ini` sets `DBPATH` and `MODELNAME`.

**UI flows that can be reproduced.**

* GCE: connect to server → pick project → open model → find concept → browse supers, subs and links.
* GCEwork: open `.grl` → syntax check → compile into a model.
* Pen&Pad: load model → DEM topic selectors (Symptom, Disease, Common Topics) → data entry form → summary sentence. The menu command IDs are listed on the [Clinergy page](/docs/clinergy/#the-fuller-setup-menu-bar-and-host-demos).

**Host integration API of Pen&Pad** (from `Documentation\PenPad API.rtf` in the demo, and the VB demo source `VBHost.frm`).

* An OLE Automation server, `PENPAD.CONNECT`, returns a `PenPadDataEntryDriver`.
* A host starts a session with `StartOLEDataEntrySession(mode, formTopic, sessionHandle, hostClass, hostType, errorCode)` or `StartWMDataEntrySession(…, WndHandle, WndMsg, errorCode)`.
* `mode` is the sum of three parts:
  * interface type: 1 Quick Data Entry, 2 Main Form, 3–7 topic selector in Symptom, Disease, Health Check, Family History or Past History mode;
  * patient sex: 256 male, 512 female;
  * 65,536 for an edit session.
* When the user accepts, Pen&Pad calls back the host class (for example `VBPenPadHost.VBHostConnector`) or posts the window message.
* The host then reads the result with `GetDataEntrySessionData` and ends with `SessionFinished`.
* Results carry text plus the GRAIL string form of each topic, and Read codes.
* That is close to how a modern web form launcher would work: start a session with context, get a callback, then fetch structured results. Under Wine the session start itself still fails (see the [Clinergy status](/docs/clinergy/#status-tested-2026-11-18)).

## Licence cautions

The Kermanog licence forbids reverse-engineering. The protocol notes above come only from watching local traffic, so the original server can be scripted on one machine. They do not come from disassembly. Run the toolset as a single user and only on a local machine.
