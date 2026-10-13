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
        // True black background for AMOLED battery savings & infinite contrast
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var statusMsg = mModel.getStatusMessage();
        if (statusMsg != null) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 195, Graphics.FONT_XTINY, statusMsg, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        var step = mModel.getCurrentStep();
        var currentStepNum = mModel.getCurrentIndex() + 1;
        var totalSteps = mModel.getTotalSteps();
        var capo = mModel.getCurrentCapo();
        var isAuto = mModel.isAutoScrolling();
        var speed = mModel.getSpeedMultiplier();

        var statusText = isAuto ? "AUTO" : "MANUAL";
        if (isAuto && speed != 1.0f) {
            statusText = Lang.format("AUTO $1$x", [speed.format("%.1f")]);
        }

        var boxY = 98;
        var lyricY = 170;

        if (capo != null) {
            // === LAYOUT FOR SONGS WITH CAPO (e.g. Hey Jude, Here Comes The Sun) ===
            // 1. Status Pill (y: 12..32, center 22)
            if (isAuto) {
                dc.setColor(0x062810, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(150, 12, 90, 20, 10);
                dc.setColor(0x00E676, Graphics.COLOR_TRANSPARENT);
                dc.drawRoundedRectangle(150, 12, 90, 20, 10);
                dc.setColor(0x00FF7F, Graphics.COLOR_TRANSPARENT);
                dc.drawText(195, 22, Graphics.FONT_XTINY, statusText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            } else {
                dc.setColor(0x181818, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(150, 12, 90, 20, 10);
                dc.setColor(0x383838, Graphics.COLOR_TRANSPARENT);
                dc.drawRoundedRectangle(150, 12, 90, 20, 10);
                dc.setColor(0x777777, Graphics.COLOR_TRANSPARENT);
                dc.drawText(195, 22, Graphics.FONT_XTINY, statusText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }

            // 2. Song Title (y: 36)
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 36, Graphics.FONT_XTINY, step[:songTitle], Graphics.TEXT_JUSTIFY_CENTER);

            // 3. Capo Badge (y: 57)
            var capoStr = "[" + (capo as Lang.String).toUpper() + "]";
            dc.setColor(0x00E5FF, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 57, Graphics.FONT_XTINY, capoStr, Graphics.TEXT_JUSTIFY_CENTER);

            // 4. Section & Step Position (y: 78)
            var statusLine = Lang.format("$1$  •  $2$/$3$", [step[:section], currentStepNum, totalSteps]);
            dc.setColor(0xFFA500, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 78, Graphics.FONT_XTINY, statusLine, Graphics.TEXT_JUSTIFY_CENTER);

            // Top Divider (y: 101)
            dc.setColor(0x242424, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(120, 101, 270, 101);

            boxY = 109;
            lyricY = 177;

        } else {
            // === LAYOUT FOR SONGS WITHOUT CAPO (e.g. Creep, Country Roads) ===
            // 1. Status Pill (y: 14..34, center 24)
            if (isAuto) {
                dc.setColor(0x062810, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(150, 14, 90, 20, 10);
                dc.setColor(0x00E676, Graphics.COLOR_TRANSPARENT);
                dc.drawRoundedRectangle(150, 14, 90, 20, 10);
                dc.setColor(0x00FF7F, Graphics.COLOR_TRANSPARENT);
                dc.drawText(195, 24, Graphics.FONT_XTINY, statusText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            } else {
                dc.setColor(0x181818, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(150, 14, 90, 20, 10);
                dc.setColor(0x383838, Graphics.COLOR_TRANSPARENT);
                dc.drawRoundedRectangle(150, 14, 90, 20, 10);
                dc.setColor(0x777777, Graphics.COLOR_TRANSPARENT);
                dc.drawText(195, 24, Graphics.FONT_XTINY, statusText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }

            // 2. Song Title (y: 40)
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 40, Graphics.FONT_XTINY, step[:songTitle], Graphics.TEXT_JUSTIFY_CENTER);

            // 3. Section & Step Position (y: 63)
            var statusLine = Lang.format("$1$  •  $2$/$3$", [step[:section], currentStepNum, totalSteps]);
            dc.setColor(0xFFA500, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 63, Graphics.FONT_XTINY, statusLine, Graphics.TEXT_JUSTIFY_CENTER);

            // Top Divider (y: 88)
            dc.setColor(0x242424, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(120, 88, 270, 88);

            boxY = 98;
            lyricY = 170;
        }

        // === 3-CHORD STAGE ===
        var chordCenterY = boxY + 24;

        // Previous Chord (left: muted soft gray)
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.drawText(80, chordCenterY, Graphics.FONT_XTINY, mModel.getPrevChord(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Current Chord Card (center: dark amber fill with crisp orange border)
        dc.setColor(0x1C1004, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(147, boxY, 96, 48, 6);

        dc.setColor(0xFF7700, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRoundedRectangle(147, boxY, 96, 48, 6);
        dc.setPenWidth(1);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, chordCenterY, Graphics.FONT_LARGE, mModel.getCurrentChord(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Next Chord (right: soft ice-cyan)
        dc.setColor(0x80CBC4, Graphics.COLOR_TRANSPARENT);
        dc.drawText(310, chordCenterY, Graphics.FONT_XTINY, mModel.getNextChord(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Stage Bottom Divider
        var stageDivY = boxY + 56;
        dc.setColor(0x242424, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(120, stageDivY, 270, stageDivY);

        // === LYRICS AREA ===
        drawWrappedLyric(dc, step[:lyric] as Lang.String?, lyricY);

        // Next Hint (safe distance below lyrics)
        var nextChord = mModel.getNextChord();
        var nextHint = (nextChord.equals("--")) ? "End of Song" : "Next: " + nextChord;
        dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, lyricY + 48, Graphics.FONT_XTINY, nextHint, Graphics.TEXT_JUSTIFY_CENTER);

        // Progress Bar
        var barY = lyricY + 74;
        dc.setColor(0x202020, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(145, barY, 100, 3, 1);

        var fillW = (100.0f * mModel.getProgressRatio()).toNumber();
        if (fillW > 0) {
            dc.setColor(0xFF7700, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(145, barY, fillW, 3, 1);
        }

        // Percentage Text
        var percent = (mModel.getProgressRatio() * 100.0f).toNumber();
        var progText = Lang.format("Step $1$/$2$ ($3$%)", [currentStepNum, totalSteps, percent]);
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, barY + 12, Graphics.FONT_XTINY, progText, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Split long lyrics across 2 compact lines with safe margins inside circular bezel
    private function drawWrappedLyric(dc as Graphics.Dc, rawLyric as Lang.String?, y as Lang.Number) as Void {
        if (rawLyric == null) {
            return;
        }

        var lyric = rawLyric as Lang.String;
        if (lyric.length() == 0) {
            return;
        }

        var font = Graphics.FONT_XTINY;
        var maxWidth = 200;

        if (dc.getTextWidthInPixels(lyric, font) <= maxWidth) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, y + 10, font, lyric, Graphics.TEXT_JUSTIFY_CENTER);
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
            dc.drawText(195, y + 10, font, lyric, Graphics.TEXT_JUSTIFY_CENTER);
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
        dc.drawText(195, y, font, line1, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(195, y + 22, font, line2, Graphics.TEXT_JUSTIFY_CENTER);
    }
}