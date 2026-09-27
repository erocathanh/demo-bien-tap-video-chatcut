# ChatCut plugin on Windows — bug report (draft v1.0, NOT SENT)

> Status: draft kept in this repo. It has not been sent to ChatCut. Sending it is the owner's decision.
> Found while testing a Claude Code skill on a clean Windows machine, 27 September 2026.
> Full Vietnamese log with timings: `LOG-LOI-WINDOWS_v1.0.md` (section 4) and `../ban-mau/dong-ho-cai-may-windows-27-09.log`.

## Environment
| | |
|---|---|
| ChatCut plugin | 1.10.14 (Claude Code plugin cache `chatcut-inc/chatcut/1.10.14`) |
| OS | Windows 11 Home 10.0.26200, x64 (i9-14900HX, 32 GB) |
| Host | Claude desktop app, Code tab. Bash tool = Git for Windows bash 5.3.9 (MSYS2). PowerShell 5.1 |
| Tools | node v24.19.0 · npm 11.17.0 · ffmpeg/ffprobe 9.0.2 full_build (winget `Gyan.FFmpeg`) · git `core.autocrlf=true` (default) |

Severity key: **blocker** = a normal user cannot finish the task · **major** = works only with a manual workaround · **minor** = wording.

---

## P5 — blocker: every video WITH AUDIO fails to upload on Windows
**Where:** `skills/asset-import/scripts/upload-media.mjs`, lines 1428–1446 (waveform step).

**What happens:** the helper builds an ffmpeg audio filter with a Windows temp file path written straight into it
(as seen in the error output; path shortened here, the helper writes under TMPDIR / os.tmpdir()):
```
ametadata=print:file=C:\Users\…\chatcut-…-waveform-….txt
```
Inside an ffmpeg filter graph, `\` and `:` are special characters, so ffmpeg cannot parse the filter and stops with:
```
No option name near 'Users…'
```
The asset is registered in the project but stays empty ("Click to relink" on the card). Videos without an audio
stream upload fine, so silent b-roll works and any talking video fails.

**Reproduce:** Windows, plugin 1.10.14, `import_media` → `create_session`, then
`node upload-media.mjs --token … --endpoint … <any .mp4 with audio>`.

**Things that do not help:** setting `TMPDIR=.` (the helper turns it into an absolute path again); retrying with
`--asset-id`; deleting the asset and uploading again (same helper, same failure).

**Suggested fix** (filter syntax checked by hand with ffmpeg; not yet tried inside the helper itself):
- turn `\` into `/` and wrap the value in escaped quotes, for example
  `ametadata=print:file=\'C:/Users/…/x.txt\'`, or
- escape twice: `C\\:/Users/…/x.txt`.
- Escaping the colon once (`C\:/…`) is **not** enough; ffmpeg still fails.
- Or avoid the file path completely and read the waveform data from stdout / a pipe.

**Impact:** the upload step of a text-based editing demo cannot run on Windows. Our skill works around it by copying
the video to Downloads, putting its path on the clipboard, and asking the user to click "Click to relink" once.

---

## P6 — major: the "preferred" loopback import is blocked inside the Claude desktop browser pane
**Where:** `serve-local-media.mjs` together with `import_media` `from_editor` / `relink_from_editor`.

**What happens:** the editor running in Claude desktop's built-in browser pane cannot reach the local media server:
requests end with `ERR_BLOCKED_BY_CLIENT`. 0 of 4 files imported. The plugin's own message says that calling it
again fails the same way. On Windows this removes the only automatic fallback for P5.

**Suggested fix:** detect the blocked request and say so in plain words, and point to the file-picker relink as the
fallback; or offer a route that does not need a loopback request from the embedded browser.

---

## P1 — major: the bundled Windows ffmpeg is unreachable after a normal install
**Where:** plugin cache `skills/asset-import/scripts/ffmpeg`; `upload-media.mjs` lines 269–275.

**What happens:** on Windows this entry is a **52-byte text file** instead of a link to the bundled `win32-x64`
ffmpeg. The repository stores it as a symbolic link, and Git on Windows checks symbolic links out as plain text
files by default (`core.symlinks=false`). The helper then cannot find its own ffmpeg, so a Windows machine without
a separately installed ffmpeg cannot upload anything.

**Suggested fix:** ship the Windows ffmpeg as a real file (or resolve it by path in code), not through a symlink.

---

## P2 — minor: the "ffmpeg missing" message only helps Mac users
**Where:** `upload-media.mjs` line 244.

**What happens:** the error only suggests `brew install ffmpeg`. A Windows user gets no usable next step.

**Suggested fix:** print the per-OS command, for example `winget install -e --id Gyan.FFmpeg` on Windows,
and mention that the terminal / app must be restarted before the new PATH is visible.

---

## P3 — minor: `login-chatcut.sh` cannot run on Windows
**Where:** `skills/chatcut-plugin-basics-claude/login-chatcut.sh`.

**What happens:** the helper needs `python3`, the `pty` module and `/tmp`. On Windows, `python3` is usually only the
Microsoft Store shortcut, and `pty` is not available. Logging in through `/mcp` → ChatCut → Authenticate **does**
work on Windows.

**Suggested fix:** state in the skill text that the helper is macOS/Linux only and that Windows users should use
`/mcp` → Authenticate.

---

## P4 — minor: instructions use the macOS `open` command
**Where:** plugin basics skill `SKILL.md`, around line 254 (`open <url>`).

**What happens:** `open` does not exist on Windows. The Windows equivalent is `start "" "<url>"`
(or `cmd /c start "" "<url>"` from Git Bash).

**Suggested fix:** give the command for each OS, or tell the agent to use the host's own way to open a URL.

---

*One more observation (an unexpected exit code while retrying with `--asset-id`) is not included: the measurement
was taken through a wrapper command, and reading the helper's code points the other way. It will be re-measured
before it is reported.*
