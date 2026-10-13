# GuitarPrompter

A smart, stage-ready guitar prompter app for Garmin smartwatches. Designed specifically for the Garmin Forerunner 165 and 165 Music (390x390 AMOLED display).

GuitarPrompter displays your guitar chords, lyrics, song sections, and capo requirements right on your wrist. Perfect for gigs, open mic sessions, busking, and band rehearsals without needing bulky music stands or smartphones.

---

## Key Features

- **Hands-Free Dynamic Auto-Scroll**:
  - Automatically advances through chords using per-step duration metadata tailored to each song's tempo.
  - Active indicator pill `[▶ AUTO]` displays in vibrant emerald green.
- **Practice Speed Multiplier (`0.8x`, `1.0x`, `1.2x`, `1.5x`)**:
  - Slow down songs to 0.8x for slow practice, or speed up to 1.2x / 1.5x for up-tempo practice.
  - Instantly cycle speeds from the control menu.
- **Tactile Haptic Feedback (Wrist Buzz)**:
  - Gives a subtle tactile pulse on chord transitions so you can keep your eyes on your fretboard, fingers, or audience without constantly watching the screen.
  - Easily toggle ON/OFF in the menu.
- **Capo Badge Indicator**:
  - Detects capo requirements and renders a neon cyan badge (e.g. `[CAPO 3]`, `[CAPO 7]`) right on the header.
- **3-Chord Stage View**:
  - **Left**: Previous chord (dimmed soft gray).
  - **Center**: Current active chord inside an amber-accented card with a glowing electric orange border.
  - **Right**: Next upcoming chord (ice-cyan accent) so your fingers can prepare the transition shape.
- **Smart Lyric Wrapping**:
  - Intelligently balances long lyric lines across two lines, keeping text safely inside the circular 390x390 AMOLED watch bezel.
- **Live Progress & Percentage**:
  - Visual progress track with real-time step counter and completion percentage (e.g., `Step 14/52 (27%)`).
- **Natural Swipe & Button Navigation**:
  - Full support for touchscreen swipes and physical hardware buttons.
- **Quick Song Restart**:
  - Instantly jump back to step 1 with one tap from the menu.
- **Direct Web Sync**:
  - Sync songs on the fly from [`songs.txt`](./songs.txt) hosted in this repository (or any custom URL).
  - Songs are saved locally with `Application.Storage` and remain saved across watch restarts.
- **AMOLED Battery-Saver UI**:
  - Pure black background (`#000000`) for infinite contrast and maximum battery efficiency on AMOLED panels.

---

## Preloaded Songs (Beginner-Friendly Open Chords)

All songs use easy open chord shapes (no barre chords):

1. **Take Me Home, Country Roads** – John Denver (Standard / No Capo: `G`, `Em`, `D`, `C`, `D7`)
2. **Hey Jude** – The Beatles (Capo 3: `D`, `A`, `G`, `D7`, `Bm`, `Em`, `A7`, `C`)
3. **Here Comes The Sun** – The Beatles (Capo 7: `D`, `G`, `A7`, `E7`, `C`)
4. **Creep** – Radiohead (Standard / No Capo: `G`, `B7`, `C`, `Cm`)
5. **Fake Plastic Trees** – Radiohead (Standard / No Capo: `D`, `Dsus4`, `G`, `Em`, `A`)
6. **Walking Back Home** – Vira Talisa (Standard / No Capo: `C`, `Em`, `Fmaj7`, `G`, `Dm`, `Am`)

---

## Controls

### Touch Screen
| Gesture / Zone | Action | Result |
| :--- | :--- | :--- |
| **Swipe Left / Up** | Swipe | Next chord |
| **Swipe Right / Down** | Swipe | Previous chord |
| **Center Zone** ($y: 80 - 160$) | Tap | Toggle auto-scroll (Play / Pause) |
| **Bottom Zone** ($y > 160$) | Tap | Next chord |
| **Top Zone** ($y < 80$) | Tap | Previous chord |

### Physical Buttons
| Button | Position | Action |
| :--- | :--- | :--- |
| **Start / Enter** | Top Right | Open controls menu (Play/Pause, Speed, Haptic, Restart, Song Picker, Web Sync) |
| **Down** | Bottom Left | Next chord |
| **Up** | Middle Left | Previous chord |
| **Back / Lap** | Bottom Right | Exit view |

---

## Controls Menu

Press the **Start / Enter** button to open the menu:

1. `▶ Play Auto-Scroll` / `⏸ Pause Auto-Scroll`: Toggle hands-free auto scrolling.
2. `⚡ Speed: 1.0x`: Tap to cycle practice speed (`1.0x` ➔ `1.2x` ➔ `1.5x` ➔ `0.8x`).
3. `📳 Haptic Buzz: ON / OFF`: Toggle wrist vibration cue on chord change.
4. `⏮ Restart Song`: Jump back to the start of the current song.
5. **Song List**: Switch between all preloaded and synced songs.
6. `🔄 Web Sync`: Download the latest songs from GitHub directly into watch storage.
7. `⚠️ Reset Songs`: Restore factory default songs anytime.

---

## Target Hardware

- Garmin Forerunner 165 (`fr165`)
- Garmin Forerunner 165 Music (`fr165m`)
- Screen: 390x390 AMOLED circular display
- Minimum Connect IQ API: `4.2.0`

---

## Building from Source

Requires the [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) (4.2.0+) and a developer signing key (`developer_key.der`).

```bash
# Build PRG for Forerunner 165
monkeyc -f monkey.jungle -o bin/GuitarPrompter.prg -d fr165 -y developer_key.der -w

# Build PRG for Forerunner 165 Music
monkeyc -f monkey.jungle -o bin/GuitarPrompter.prg -d fr165m -y developer_key.der -w
```

Run in the Connect IQ Simulator:
```bash
connectiq
monkeydo bin/GuitarPrompter.prg fr165
```

---

## Customizing Songs & Web Sync

You can edit [`songs.txt`](./songs.txt) or host your own text file using standard ChordPro format with optional timing in seconds:

```text
# Song Title - Artist (Capo 3)
{capo: Capo 3}
[G:3] Almost heaven, West Virginia
[Em:3] Blue Ridge Mountains, Shenandoah
[D:2.5] Younger than the mountains
[C:2] Growin' like a breeze
```

- Each song starts with `# Song Title`.
- Add `{capo: Capo X}` or put `(Capo X)` in the title line to display the capo badge.
- Specify timing in brackets: `[Chord:Seconds]`.
- Tap **🔄 Web Sync** on your watch to download and persist changes immediately.