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

        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        var statusMsg = mModel.getStatusMessage();
        if (statusMsg != null) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 195, Graphics.FONT_XTINY, statusMsg, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        // === 1. CIRCULAR BEZEL PROGRESS ARC ===
        drawProgressArc(dc, mModel.getProgressRatio());

        var step = mModel.getCurrentStep();
        var capo = mModel.getCurrentCapo();
        var isAuto = mModel.isAutoScrolling();
        var speed = mModel.getSpeedMultiplier();

        // === 2. AUTO STATUS BADGE (Only when auto-scrolling is active) ===
        if (isAuto) {
            var autoText = (speed == 1.0f) ? "AUTO" : Lang.format("AUTO $1$x", [speed.format("%.1f")]);
            dc.setColor(0x00E676, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 12, Graphics.FONT_XTINY, autoText, Graphics.TEXT_JUSTIFY_CENTER);
        }

        // === 3. HEADER: SONG TITLE & SECTION / CAPO (No lines) ===
        // Title (Crisp White, FONT_XTINY)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 32, Graphics.FONT_XTINY, step[:songTitle], Graphics.TEXT_JUSTIFY_CENTER);

        // Section & Capo on single sub-header line
        var subHeader = step[:section];
        if (capo != null) {
            subHeader = subHeader + "  •  " + (capo as Lang.String).toUpper();
        }
        dc.setColor(0xFFA500, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 56, Graphics.FONT_XTINY, subHeader, Graphics.TEXT_JUSTIFY_CENTER);

        // === 4. NOW (ACTIVE) CHORD & LYRICS ===
        // Current Chord: Medium font (clean, legible, not oversized), Electric Green
        var curChord = mModel.getCurrentChord();
        var curFont = (curChord.length() > 4) ? Graphics.FONT_SMALL : Graphics.FONT_MEDIUM;
        dc.setColor(0x00FF7F, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 100, curFont, curChord, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Current Lyrics (White, FONT_XTINY, 1 or 2 lines)
        drawCleanLyric(dc, step[:lyric] as Lang.String?, 130, 124, Graphics.COLOR_WHITE);

        // === 5. NEXT (PREVIEW) CHORD & LYRICS (No lines, no "NEXT" text) ===
        var nextChord = mModel.getNextChord();
        var nextLyric = mModel.getNextLyric();

        if (!nextChord.equals("--")) {
            // Next Chord: Small/XTiny font (modest, subtle preview), Soft Ice Cyan
            dc.setColor(0x80CBC4, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 212, Graphics.FONT_XTINY, nextChord, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            // Next Lyrics: Small FONT_XTINY, Muted Gray, 1 or 2 lines into bottom space
            drawCleanLyric(dc, nextLyric, 240, 234, 0x666666);
        } else {
            // End of Song State
            dc.setColor(0x444444, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 212, Graphics.FONT_XTINY, "---", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(195, 238, Graphics.FONT_XTINY, "(End of song)", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // Circular progress arc hugging the outer bezel edge
    private function drawProgressArc(dc as Graphics.Dc, ratio as Lang.Float) as Void {
        var cx = 195;
        var cy = 195;
        var r = 191; // Just inside 195 outer bezel edge

        // 1. Subtle dark circular track
        dc.setColor(0x181818, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawArc(cx, cy, r, Graphics.ARC_CLOCKWISE, 0, 0);

        // 2. Filled progress arc running clockwise from 12 o'clock (90 deg)
        var sweep = (ratio * 360.0f).toNumber();
        if (sweep > 0) {
            dc.setColor(0x00E676, Graphics.COLOR_TRANSPARENT); // Vivid Emerald Green
            dc.setPenWidth(3);

            if (ratio >= 1.0f || sweep >= 360) {
                // Complete 360 circle
                dc.drawArc(cx, cy, r, Graphics.ARC_CLOCKWISE, 90, 90);
            } else {
                var endDeg = (90 - sweep + 360) % 360;
                if (endDeg == 90) {
                    endDeg = 89;
                }
                dc.drawArc(cx, cy, r, Graphics.ARC_CLOCKWISE, 90, endDeg);
            }
        }

        // Restore pen width to default
        dc.setPenWidth(1);
    }

    // Clean lyric renderer with smart 1 or 2 line positioning and zero overlap
    private function drawCleanLyric(dc as Graphics.Dc, rawText as Lang.String?, y1Line as Lang.Number, y2Line as Lang.Number, color as Lang.Number) as Void {
        if (rawText == null) {
            return;
        }

        var text = rawText as Lang.String;
        if (text.length() == 0) {
            return;
        }

        var font = Graphics.FONT_XTINY;
        var maxW = 230;

        // Fits in 1 single line
        if (dc.getTextWidthInPixels(text, font) <= maxW) {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, y1Line, font, text, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        // Tokenize words
        var words = [] as Lang.Array<Lang.String>;
        var remaining = text;
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
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, y1Line, font, text, Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        // Find optimal split point between line 1 and line 2
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
            if (w1 > maxW) {
                penalty += 500;
            }
            if (w2 > maxW) {
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

        // Truncate line 2 if it still exceeds max width
        if (dc.getTextWidthInPixels(line2, font) > maxW) {
            while (line2.length() > 0 && dc.getTextWidthInPixels(line2 + "...", font) > maxW) {
                line2 = line2.substring(0, line2.length() - 1) as Lang.String;
            }
            line2 = line2 + "...";
        }

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, y2Line, font, line1, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(195, y2Line + 22, font, line2, Graphics.TEXT_JUSTIFY_CENTER);
    }
}