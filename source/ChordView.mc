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

        // 1. Slim Status Pill at top (Standard ASCII, compact width 80, height 16)
        var statusText = isAuto ? "AUTO" : "MANUAL";
        if (isAuto && speed != 1.0f) {
            statusText = Lang.format("AUTO $1$x", [speed.format("%.1f")]);
        }

        if (isAuto) {
            dc.setColor(0x062810, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(155, 18, 80, 16, 8);
            dc.setColor(0x00E676, Graphics.COLOR_TRANSPARENT);
            dc.drawRoundedRectangle(155, 18, 80, 16, 8);
            dc.setColor(0x00FF7F, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 18, Graphics.FONT_XTINY, statusText, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(0x181818, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(155, 18, 80, 16, 8);
            dc.setColor(0x383838, Graphics.COLOR_TRANSPARENT);
            dc.drawRoundedRectangle(155, 18, 80, 16, 8);
            dc.setColor(0x777777, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 18, Graphics.FONT_XTINY, statusText, Graphics.TEXT_JUSTIFY_CENTER);
        }

        // 2. Header: Song Title & Section (Compact FONT_XTINY)
        var boxY = 100;
        var lyricY = 178;

        if (capo != null) {
            // Capo badge in neon cyan
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 40, Graphics.FONT_XTINY, step[:songTitle], Graphics.TEXT_JUSTIFY_CENTER);

            var capoStr = "[" + (capo as Lang.String).toUpper() + "]";
            dc.setColor(0x00E5FF, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 58, Graphics.FONT_XTINY, capoStr, Graphics.TEXT_JUSTIFY_CENTER);

            var statusLine = Lang.format("$1$  •  $2$/$3$", [step[:section], currentStepNum, totalSteps]);
            dc.setColor(0xFFA500, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 76, Graphics.FONT_XTINY, statusLine, Graphics.TEXT_JUSTIFY_CENTER);

            dc.setColor(0x242424, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(130, 94, 260, 94);

            boxY = 106;
            lyricY = 184;
        } else {
            // Standard layout without Capo
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 42, Graphics.FONT_XTINY, step[:songTitle], Graphics.TEXT_JUSTIFY_CENTER);

            var statusLine = Lang.format("$1$  •  $2$/$3$", [step[:section], currentStepNum, totalSteps]);
            dc.setColor(0xFFA500, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 62, Graphics.FONT_XTINY, statusLine, Graphics.TEXT_JUSTIFY_CENTER);

            dc.setColor(0x242424, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(130, 82, 260, 82);

            boxY = 94;
            lyricY = 172;
        }

        // 3. Middle Stage: 3-Chord Horizontal Display (Proportional, sleek sizes)
        var prevChord = mModel.getPrevChord();
        var currentChord = mModel.getCurrentChord();
        var nextChord = mModel.getNextChord();
        var chordCenterY = boxY + 23;

        // Previous chord (left: muted soft gray, FONT_XTINY)
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.drawText(85, chordCenterY, Graphics.FONT_XTINY, prevChord, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Current chord card (center: sleek compact card with warm glow)
        dc.setColor(0x1C1004, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(147, boxY, 96, 46, 6);

        dc.setColor(0xFF7700, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRoundedRectangle(147, boxY, 96, 46, 6);
        dc.setPenWidth(1);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, chordCenterY, Graphics.FONT_LARGE, currentChord, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Next chord (right: soft ice-cyan, FONT_XTINY)
        dc.setColor(0x80CBC4, Graphics.COLOR_TRANSPARENT);
        dc.drawText(305, chordCenterY, Graphics.FONT_XTINY, nextChord, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Stage bottom divider
        var stageDivY = boxY + 54;
        dc.setColor(0x242424, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(130, stageDivY, 260, stageDivY);

        // 4. Lyric area (Compact FONT_XTINY, clean line wrap, safely inside bezel)
        drawWrappedLyric(dc, step[:lyric] as Lang.String?, lyricY);

        // Next chord teaser hint
        var nextHint = (nextChord.equals("--")) ? "End of Song" : "Next: " + nextChord;
        dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, lyricY + 36, Graphics.FONT_XTINY, nextHint, Graphics.TEXT_JUSTIFY_CENTER);

        // 5. Slim bottom progress bar
        var barY = lyricY + 60;
        dc.setColor(0x202020, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(145, barY, 100, 3, 1);

        var fillW = (100.0f * mModel.getProgressRatio()).toNumber();
        if (fillW > 0) {
            dc.setColor(0xFF7700, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(145, barY, fillW, 3, 1);
        }

        // Step percentage footer
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

        // FONT_XTINY gives clean, compact, non-crowded readability
        var font = Graphics.FONT_XTINY;
        var maxWidth = 200;

        if (dc.getTextWidthInPixels(lyric, font) <= maxWidth) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, y + 6, font, lyric, Graphics.TEXT_JUSTIFY_CENTER);
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
            dc.drawText(195, y + 6, font, lyric, Graphics.TEXT_JUSTIFY_CENTER);
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
        dc.drawText(195, y + 16, font, line2, Graphics.TEXT_JUSTIFY_CENTER);
    }
}