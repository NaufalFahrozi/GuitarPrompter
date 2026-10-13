# GuitarPrompter

A Garmin Connect IQ watch app that displays guitar chords and lyrics right on your wrist. Built for the Forerunner 165 and 165 Music (390x390 AMOLED).

Useful for rehearsals, busking, acoustic gigs, or open mic nights when you don't want a music stand or smartphone in front of you.

---

## Features

- **Dynamic Auto-Scroll**: Automatically advances chords based on each song's tempo and per-chord durations. Displays a green `[▶ AUTO]` badge on screen while running.
- **3-Chord Stage View**: 
  - Left: Previous chord (dimmed).
  - Center: Current chord in large text with an orange rounded border.
  - Right: Next chord (dimmed) so you can prepare your next hand shape.
- **Smart Lyric Wrapping**: Long lyric lines are split across two centered lines so text won't get cut off by the watch's circular bezel.
- **6 Preloaded Songs**: Comes with 6 complete acoustic songs using easy open chords (no hard barre chords, capo tips included):
  1. *Country Roads* – John Denver (No Capo: G, Em, D, C, D7)
  2. *Hey Jude* – The Beatles (Capo 3: D, A, G, D7, Bm, Em, A7, C)
  3. *Here Comes The Sun* – The Beatles (Capo 7: D, G, A7, E7, C)
  4. *Creep* – Radiohead (No Capo: G, B7, C, Cm)
  5. *Fake Plastic Trees* – Radiohead (No Capo: D, Dsus4, G, Em, A)
  6. *Walking Back Home* – Vira Talisa (No Capo: C, Em, Fmaj7, G, Dm, Am)
- **Direct Web Sync**: Syncs songs directly from [`songs.txt`](./songs.txt) in this repository or custom raw links. Songs persist across app restarts via `Application.Storage`.
- **Battery-Friendly UI**: Pure black background (`#000000`) for maximum AMOLED power efficiency and high visibility under stage lights.

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
songs.txt              # Complete ChordPro database with 6 songs
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

You can add or customize songs in `songs.txt`. The app supports ChordPro syntax with optional per-chord timing in seconds:

```text
# Song Title
[G:3] Almost heaven, West Virginia
[Em:3] Blue Ridge Mountains, Shenandoah
[D:2.5] Younger than the mountains
[C:2] Growin' like a breeze
```

To sync on the watch, select **🔄 Web Sync** from the menu. You can also select **⏮ Reset Songs** to reload the 6 default songs anytime.