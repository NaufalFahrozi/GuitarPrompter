# 🎸 GuitarPrompter

> **Hands-free Guitar Chord & Lyric Prompter for Garmin Forerunner 165 / 165 Music**  
> Dibangun dengan Garmin Connect IQ SDK & Monkey C untuk layar melingkar AMOLED 390x390.

---

## 📖 Ringkasan Proyek

**GuitarPrompter** adalah aplikasi prompter kunci gitar cerdas yang dirancang khusus untuk jam tangan Garmin (khususnya seri Forerunner 165 & 165 Music). Aplikasi ini memungkinkan gitaris dan musisi membaca akor (chord) serta lirik lagu langsung dari pergelangan tangan secara *hands-free* saat tampil di panggung atau latihan.

Dengan kombinasi layar AMOLED beresolusi tinggi, navigasi sentuh cepat, tombol fisik, serta mode auto-scroll otomatis, musisi tidak perlu lagi membolak-balik lembaran kertas chord atau menyentuh layar smartphone saat kedua tangan sedang memegang instrumen.

---

## ✨ Fitur Utama

- ⏱️ **Hands-Free Auto-Scroll**:
  - Fitur pengguliran otomatis berbasis `Toybox.Timer.Timer` dengan interval default **3.5 detik**.
  - Dilengkapi indikator visual `[▶ AUTO]` berwarna hijau di puncak layar saat auto-scroll aktif.
  - Auto-scroll akan otomatis berhenti jika sudah mencapai bait/langkah terakhir lagu.

- 🎼 **Tampilan Panggung Horizontal 3 Chord**:
  - **Kiri (Previous Chord)**: Menampilkan kunci sebelumnya dengan warna abu-abu redup.
  - **Tengah (Current Chord)**: Menampilkan kunci aktif berukuran besar dengan border rounded oranye cerah berkontras tinggi agar mudah dibaca sekilas.
  - **Kanan (Next Chord)**: Menampilkan kunci berikutnya dengan warna abu-abu redup untuk persiapan pergantian chord.

- 🔤 **Smart 2-Line Lyric Wrapping**:
  - Algoritma pemecah lirik adaptif yang mengukur panjang piksel teks (`getTextWidthInPixels`).
  - Lirik panjang otomatis dipecah menjadi 2 baris terpusat berdasarkan batas kata sehingga tidak terpotong oleh bezel layar bulat 390x390.

- 🌐 **Web Sync / Cloud ChordPro Integration**:
  - Sinkronisasi daftar lagu dan lirik baru langsung dari internet (URL Raw GitHub Gist / Pastebin) via `Toybox.Communications.makeWebRequest`.
  - Mendukung parsing format ChordPro ringkas.
  - Data lagu disimpan secara permanen di memori jam menggunakan `Toybox.Application.Storage`.

- 🔋 **Efisiensi Baterai AMOLED**:
  - Menggunakan palet hitam pekat (*true black* `0x000000`) untuk efisiensi konsumsi daya layar AMOLED dan visibilitas maksimal di pencahayaan redup/panggung.

---

## 🎮 Kontrol & Navigasi

Aplikasi ini mendukung kontrol layar sentuh maupun tombol fisik jam tangan Garmin:

### 1. Layar Sentuh (*Touch Gestures*)
| Area Layar | Aksi | Fungsi |
| :--- | :---: | :--- |
| **Area Tengah** ($y: 80 - 160$) | Ketuk (*Tap*) | **Toggle Auto-Scroll** (Mulai / Jeda scroll otomatis) |
| **Area Bawah** ($y > 160$) | Ketuk (*Tap*) | **Maju ke Chord Selanjutnya** (*Next Step*) |
| **Area Atas** ($y < 80$) | Ketuk (*Tap*) | **Mundur ke Chord Sebelumnya** (*Previous Step*) |

### 2. Tombol Fisik (*Hardware Buttons*)
| Tombol | Fungsi |
| :--- | :--- |
| **Start / Enter** (Kanan Atas) | Membuka **Menu2** (Play/Pause Auto-Scroll, Daftar Pilihan Lagu, dan Sync dari Web) |
| **Down** (Kiri Bawah) | Maju ke langkah chord selanjutnya |
| **Up** (Kiri Tengah) | Mundur ke langkah chord sebelumnya |
| **Back / Lap** (Kanan Bawah) | Kembali / Keluar dari menu |

---

## 📁 Struktur Kode & Arsitektur

```text
GuitarPrompter/
├── manifest.xml           # Konfigurasi aplikasi Connect IQ, izin, & target perangkat
├── monkey.jungle          # Konfigurasi jungle build Garmin
├── resources/             # Resource XML (string, drawable launcher icon 54x54)
└── source/
    ├── App.mc             # GuitarPrompterApp: Titik masuk aplikasi (AppBase)
    ├── SongModel.mc       # Data layer: Penyimpanan lagu, timer auto-scroll, Web Sync
    ├── ChordView.mc       # Presentation layer: Rendering AMOLED, 3 chord bar, lyric wrapping
    └── ChordDelegate.mc   # Controller layer: BehaviorDelegate, touch listener, Menu2 delegate
```

### Rincian Modul:
1. **[SongModel.mc](file:///c:/NopalBikinAplikasi/GuitarPrompter/source/SongModel.mc)**:
   - Menyimpan daftar lagu default (*Country Roads*, *Hold Your Hand*) dan lagu hasil sinkronisasi.
   - Mengelola `Timer.Timer` untuk Auto-Scroll interval 3.5 detik.
   - Menyediakan getter: `getPrevChord()`, `getCurrentChord()`, dan `getNextChord()`.
   - Menggunakan `Storage.setValue("SAVED_SONGS", mSongs as Application.Storage.ValueType)` untuk kompatibilitas strict storage.

2. **[ChordView.mc](file:///c:/NopalBikinAplikasi/GuitarPrompter/source/ChordView.mc)**:
   - Menggambar status lagu, nomor step, dan garis pemisah.
   - Menggambar layout 3 chord horizontal berjajar dengan border aksen oranye.
   - Mengimplementasikan `drawWrappedLyric` untuk membagi baris lirik secara proporsional.
   - Menampilkan progress bar di bagian bawah layar.

3. **[ChordDelegate.mc](file:///c:/NopalBikinAplikasi/GuitarPrompter/source/ChordDelegate.mc)**:
   - Menangkap gesture sentuhan dan tombol fisik.
   - Menampilkan `WatchUi.Menu2` untuk memilih lagu atau mengaktifkan/menonaktifkan auto-scroll.

---

## 🛠️ Kompatibilitas Perangkat

Aplikasi ini dikonfigurasi dan dioptimalkan untuk:
- **Garmin Forerunner 165** (`fr165`) - AMOLED 390x390
- **Garmin Forerunner 165 Music** (`fr165m`) - AMOLED 390x390
- Minimum Connect IQ API Level: `4.2.0`

---

## 💻 Cara Build & Menjalankan

### Prasyarat
- Garmin Connect IQ SDK versi 4.2.0 atau lebih baru (disarankan SDK 9.x).
- Java Runtime Environment (JRE).
- Developer Private Key (`.der`) untuk penandatanganan aplikasi.

### Kompilasi Menggunakan CLI
Jalankan perintah berikut di direktori proyek:

```bash
# Build untuk Forerunner 165
monkeyc -f monkey.jungle -o bin/GuitarPrompter.prg -d fr165 -y developer_key.der -w

# Build untuk Forerunner 165 Music
monkeyc -f monkey.jungle -o bin/GuitarPrompter.prg -d fr165m -y developer_key.der -w
```

### Menjalankan di Connect IQ Simulator
```bash
connectiq.bat
monkeydo bin/GuitarPrompter.prg fr165
```

---

## 📝 Format Sinkronisasi Lagu (ChordPro)

Untuk menyinkronkan lagu baru melalui fitur **Sync dari Web**, gunakan format teks mentah (*raw text*) seperti berikut pada Gist/Pastebin:

```text
# Judul Lagu
[G] Bait pertama lirik lagu
[Em] Bait kedua lirik lagu
[C] Bait ketiga lirik lagu
[D] Bait keempat lirik lagu

# Lagu Kedua
[Am] Lirik lagu kedua
[F] Lirik lanjutan
```

Ganti nilai `mSyncUrl` di `source/SongModel.mc` dengan URL raw milik Anda sendiri.

---

## 📄 Lisensi

Proyek ini dikembangkan untuk penggunaan pribadi dan komunitas musisi Garmin Connect IQ.