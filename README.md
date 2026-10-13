# GuitarPrompter

A Garmin Connect IQ watch app that displays guitar chords and lyrics right on your wrist. Built for the Forerunner 165 and 165 Music (390x390 AMOLED).

Useful for rehearsals, busking, acoustic gigs, or open mic nights when you don't want a music stand or smartphone in front of you.

---

## Features

- **Dynamic Auto-Scroll**: Automatically advances chords based on the song's tempo and individual chord durations. Displays a green `[▶ AUTO]` badge on screen while running.
- **3-Chord Stage View**: 
  - Left: Previous chord (dimmed).
  - Center: Current chord in large text with an orange rounded border.
  - Right: Next chord (dimmed) so you can prepare your next hand shape.
- **Smart Lyric Wrapping**: Long lyric lines are split across two centered lines so text won't get cut off by the watch's circular bezel.
- **Built-in Song Repertoire**: Comes preloaded with 3 ready-to-play songs:
  1. *Take Me Home, Country Roads* – John Denver (~82 BPM)
  2. *Creep* – Radiohead (~92 BPM, 5.2s per measure)
  3. *Hey Jude* – The Beatles (~74 BPM)
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
| **Start / Enter** (Top Right) | Open menu (Play/Pause auto-scroll, song list, web sync, reset songs) |
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
├── SongModel.mc       # Song data, dynamic per-step auto-scroll, web sync, storage
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

You can host songs as raw text on GitHub Gist or Pastebin. You can specify custom durations per chord (in seconds) or let them use the default tempo:

```text
# Song Title
[G:3] Almost heaven, West Virginia
[Em:3] Blue Ridge Mountains, Shenandoah
[D:2.5] Younger than the mountains
[C:2.5] Growin' like a breeze

# Another Song
[G:5.2] When you were here before
[B:5.2] Couldn't look you in the eye
[C:5.2] You're just like an angel
[Cm:5.2] Your skin makes me cry
```

Update `mSyncUrl` in `source/SongModel.mc` with your raw URL, then hit **Sync dari Web** in the watch menu. You can also select **Reset Lagu Bawaan** to reload the default songs anytime.