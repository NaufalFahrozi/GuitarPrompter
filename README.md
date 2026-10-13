# GuitarPrompter

A Garmin Connect IQ watch app that displays guitar chords and lyrics right on your wrist. Built for the Forerunner 165 and 165 Music (390x390 AMOLED).

Useful for rehearsals, busking, acoustic gigs, or open mic nights when you don't want a music stand or smartphone in front of you.

---

## Features

- **Hands-Free Auto-Scroll**: Advances chords automatically so you don't have to take your hands off the fretboard. Defaults to 3.5 seconds per chord, with a green `[▶ AUTO]` tag on screen while running.
- **3-Chord Stage View**: 
  - Left: Previous chord (dimmed).
  - Center: Current chord in large text with an orange rounded border.
  - Right: Next chord (dimmed) so you can prepare your next hand shape.
- **Smart Lyric Wrapping**: Long lyric lines are split across two centered lines so text won't get cut off by the watch's circular bezel.
- **Web Sync**: Download song repertoires directly from a raw web link (like a GitHub Gist or Pastebin) formatted in simple ChordPro style. Songs persist across app restarts using `Application.Storage`.
- **Battery-Friendly UI**: Pure black background (`#000000`) to save battery on AMOLED screens and keep visibility high under stage lighting.

---

## Controls

### Touch Screen
| Zone | Action | Result |
| :--- | :--- | :--- |
| **Center** ($y: 80 - 160$) | Tap | Toggle auto-scroll (Play / Pause) |
| **Bottom** ($y > 160$) | Tap | Next chord |
| **Top** ($y < 80$) | Tap | Previous chord |

### Buttons
| Button | Result |
| :--- | :--- |
| **Start / Enter** (Top Right) | Open menu (Play/Pause auto-scroll, song list, web sync) |
| **Down** (Bottom Left) | Next chord |
| **Up** (Middle Left) | Previous chord |
| **Back** (Bottom Right) | Back / Exit |

---

## Target Devices

- Garmin Forerunner 165 (`fr165`)
- Garmin Forerunner 165 Music (`fr165m`)
- Minimum Connect IQ API: `4.2.0`

---

## Project Structure

```text
source/
├── App.mc             # App entry point (AppBase)
├── SongModel.mc       # Song data, timer-based auto-scroll, web sync, storage
├── ChordView.mc       # AMOLED UI layout, 3-chord view, text wrapping
└── ChordDelegate.mc   # Button mappings, touch coordinates, Menu2 handling
```

---

## Building from Source

You'll need the [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) (4.2.0+) and a developer signing key (`.der`).

Compile using `monkeyc`:

```bash
# Build for Forerunner 165
monkeyc -f monkey.jungle -o bin/GuitarPrompter.prg -d fr165 -y developer_key.der -w

# Build for Forerunner 165 Music
monkeyc -f monkey.jungle -o bin/GuitarPrompter.prg -d fr165m -y developer_key.der -w
```

Run in the simulator:
```bash
connectiq
monkeydo bin/GuitarPrompter.prg fr165
```

---

## Adding Songs via Web Sync

You can host songs as raw text on GitHub Gist or Pastebin using this format:

```text
# Song Title 1
[G] Almost heaven, West Virginia
[Em] Blue Ridge Mountains, Shenandoah
[D] Younger than mountains

# Song Title 2
[C] Some other lyric line
[G] Another chord line
```

Update `mSyncUrl` in `source/SongModel.mc` with your raw URL, then hit **Sync dari Web** in the watch menu.