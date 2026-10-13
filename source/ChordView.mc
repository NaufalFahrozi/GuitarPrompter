import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:typecheck(strict))
class ChordView extends WatchUi.View {
    private var mModel as SongModel;

    public function initialize(model as SongModel) {
        View.initialize();
        mModel = model;
    }

    public function onUpdate(dc as Graphics.Dc) as Void {
        // Layar hitam pekat untuk efisiensi baterai AMOLED
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var statusMsg = mModel.getStatusMessage();
        if (statusMsg != null) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 195, Graphics.FONT_MEDIUM, statusMsg, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        var step = mModel.getCurrentStep();
        var currentStepNum = mModel.getCurrentIndex() + 1;
        var totalSteps = mModel.getTotalSteps();

        // 1. Indikator Auto-Scroll (Warna hijau di bagian paling atas jika aktif)
        if (mModel.isAutoScrolling()) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 26, Graphics.FONT_XTINY, "[▶ AUTO]", Graphics.TEXT_JUSTIFY_CENTER);
        }

        // 2. Bagian Atas: Judul Lagu & Nomor Step
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 48, Graphics.FONT_XTINY, step[:songTitle], Graphics.TEXT_JUSTIFY_CENTER);

        var statusLine = Lang.format("$1$  •  $2$/$3$", [step[:section], currentStepNum, totalSteps]);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 72, Graphics.FONT_XTINY, statusLine, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(0x2A2A2A, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(100, 96, 290, 96);

        // 3. Bagian Tengah: Horizontal 3 Chord berjajar (Prev di kiri, Current besar dengan border oranye di tengah, Next di kanan)
        var prevChord = mModel.getPrevChord();
        var currentChord = mModel.getCurrentChord();
        var nextChord = mModel.getNextChord();

        // Kunci Sebelumnya (Kiri)
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(75, 146, Graphics.FONT_MEDIUM, prevChord, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Kunci Aktif (Tengah, Besar, Border Oranye)
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRoundedRectangle(140, 116, 110, 60, 8);
        dc.setPenWidth(1);
        dc.drawText(195, 146, Graphics.FONT_SYSTEM_LARGE, currentChord, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Kunci Selanjutnya (Kanan)
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(315, 146, Graphics.FONT_MEDIUM, nextChord, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(0x2A2A2A, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(90, 196, 300, 196);

        // 4. Bagian Bawah: Lirik Aktif (Dipecah 2 baris jika panjang)
        drawWrappedLyric(dc, step[:lyric] as Lang.String?, 232);

        var nextHint = (nextChord.equals("--")) ? "Selesai" : "Berikutnya: " + nextChord;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 280, Graphics.FONT_XTINY, nextHint, Graphics.TEXT_JUSTIFY_CENTER);

        // 5. Garis Progres Lagu
        dc.setColor(0x222222, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(135, 330, 120, 4, 2);

        var fillW = (120.0f * mModel.getProgressRatio()).toNumber();
        if (fillW > 0) {
            dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(135, 330, fillW, 4, 2);
        }
    }

    // Fungsi untuk memecah lirik panjang menjadi 2 baris agar tidak terpotong oleh layar bulat 390x390
    private function drawWrappedLyric(dc as Graphics.Dc, rawLyric as Lang.String?, y as Lang.Number) as Void {
        if (rawLyric == null) {
            return;
        }

        var lyric = rawLyric as Lang.String;
        if (lyric.length() == 0) {
            return;
        }

        var font = Graphics.FONT_SMALL;
        var maxWidth = 260;

        if (dc.getTextWidthInPixels(lyric, font) <= maxWidth) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, y, font, lyric, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        var words = [] as Lang.Array<Lang.String>;
        var remaining = lyric;
        while (remaining.length() > 0) {
            var sp = remaining.find(" ");
            if (sp != null) {
                var spaceIndex = sp as Lang.Number;
                var w = remaining.substring(0, spaceIndex);
                if (w != null && w.length() > 0) {
                    words.add(w as Lang.String);
                }
                var nextStart = spaceIndex + 1;
                if (nextStart < remaining.length()) {
                    var rest = remaining.substring(nextStart, remaining.length());
                    remaining = (rest != null) ? (rest as Lang.String) : "";
                } else {
                    remaining = "";
                }
            } else {
                words.add(remaining);
                remaining = "";
            }
        }

        if (words.size() <= 1) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, y, font, lyric, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        var bestSplit = 0;
        var minDiff = 10000;

        for (var i = 0; i < words.size() - 1; i++) {
            var l1 = "";
            for (var a = 0; a <= i; a++) {
                l1 = (l1.length() == 0) ? words[a] : l1 + " " + words[a];
            }
            var l2 = "";
            for (var b = i + 1; b < words.size(); b++) {
                l2 = (l2.length() == 0) ? words[b] : l2 + " " + words[b];
            }
            var w1 = dc.getTextWidthInPixels(l1, font);
            var w2 = dc.getTextWidthInPixels(l2, font);

            var penalty = 0;
            if (w1 > maxWidth) {
                penalty += 500;
            }
            if (w2 > maxWidth) {
                penalty += 500;
            }

            var diff = (w1 > w2 ? w1 - w2 : w2 - w1) + penalty;
            if (diff < minDiff) {
                minDiff = diff;
                bestSplit = i;
            }
        }

        var line1 = "";
        for (var a = 0; a <= bestSplit; a++) {
            line1 = (line1.length() == 0) ? words[a] : line1 + " " + words[a];
        }
        var line2 = "";
        for (var b = bestSplit + 1; b < words.size(); b++) {
            line2 = (line2.length() == 0) ? words[b] : line2 + " " + words[b];
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, y - 13, font, line1, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(195, y + 13, font, line2, Graphics.TEXT_JUSTIFY_CENTER);
    }
}