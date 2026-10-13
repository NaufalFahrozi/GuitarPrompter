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

        var statusText = isAuto ? "AUTO" : "MANUAL";
        if (isAuto && speed != 1.0f) {
            statusText = Lang.format("AUTO $1$x", [speed.format("%.1f")]);
        }

        // === 2. TOP STATUS PILL ===
        var pillW = (isAuto && speed != 1.0f) ? 88 : 74;
        var pillX = 195 - (pillW / 2);
        if (isAuto) {
            dc.setColor(0x062810, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(pillX, 12, pillW, 18, 9);
            dc.setColor(0x00E676, Graphics.COLOR_TRANSPARENT);
            dc.drawRoundedRectangle(pillX, 12, pillW, 18, 9);
            dc.setColor(0x00FF7F, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 20, Graphics.FONT_XTINY, statusText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            dc.setColor(0x181818, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(pillX, 12, pillW, 18, 9);
            dc.setColor(0x383838, Graphics.COLOR_TRANSPARENT);
            dc.drawRoundedRectangle(pillX, 12, pillW, 18, 9);
            dc.setColor(0x777777, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 20, Graphics.FONT_XTINY, statusText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // === 3. SONG TITLE ===
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 36, Graphics.FONT_XTINY, step[:songTitle], Graphics.TEXT_JUSTIFY_CENTER);

        var sectionY = 58;
        var divY = 82;
        var chordCenterY = 112;

        if (capo != null) {
            // Capo Badge
            var capoStr = "[" + (capo as Lang.String).toUpper() + "]";
            dc.setColor(0x00E5FF, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 56, Graphics.FONT_XTINY, capoStr, Graphics.TEXT_JUSTIFY_CENTER);

            sectionY = 76;
            divY = 98;
            chordCenterY = 124;
        }

        // === 4. SECTION NAME ONLY (No step numbers) ===
        dc.setColor(0xFFA500, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, sectionY, Graphics.FONT_XTINY, step[:section], Graphics.TEXT_JUSTIFY_CENTER);

        // Header Divider
        dc.setColor(0x222222, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(120, divY, 270, divY);

        // === 5. 3-CHORD STAGE (Clean, Minimalist, No Box) ===
        // Previous Chord (left: muted soft gray)
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.drawText(80, chordCenterY, Graphics.FONT_XTINY, mModel.getPrevChord(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Active Current Chord (center: Vibrant Electric Green, no bounding box)
        dc.setColor(0x00FF7F, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, chordCenterY, Graphics.FONT_MEDIUM, mModel.getCurrentChord(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Next Chord (right: soft ice-cyan)
        dc.setColor(0x80CBC4, Graphics.COLOR_TRANSPARENT);
        dc.drawText(310, chordCenterY, Graphics.FONT_XTINY, mModel.getNextChord(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Stage Bottom Divider
        var stageDivY = chordCenterY + 26;
        dc.setColor(0x222222, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(130, stageDivY, 260, stageDivY);

        // === 6. ACTIVE LYRIC ===
        var lyricY = stageDivY + 12;
        var lyricBottomY = drawWrappedLyric(dc, step[:lyric] as Lang.String?, lyricY);

        // === 7. NEXT LYRIC PREVIEW (Upcoming Line Hint) ===
        var nextLyric = mModel.getNextLyric();
        var nextLyricY = lyricBottomY + 14;

        if (nextLyric != null && (nextLyric as Lang.String).length() > 0) {
            var nl = nextLyric as Lang.String;
            var maxNextWidth = 240;
            var fontTiny = Graphics.FONT_XTINY;

            if (dc.getTextWidthInPixels(nl, fontTiny) > maxNextWidth) {
                while (nl.length() > 0 && dc.getTextWidthInPixels(nl + "...", fontTiny) > maxNextWidth) {
                    nl = nl.substring(0, nl.length() - 1) as Lang.String;
                }
                nl = nl + "...";
            }

            dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, nextLyricY, fontTiny, nl, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(0x444444, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, nextLyricY, Graphics.FONT_XTINY, "(End of song)", Graphics.TEXT_JUSTIFY_CENTER);
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

    // Split long lyrics across 1 or 2 compact lines with safe margins inside circular bezel
    // Returns the bottom Y coordinate of the rendered lyric
    private function drawWrappedLyric(dc as Graphics.Dc, rawLyric as Lang.String?, y as Lang.Number) as Lang.Number {
        if (rawLyric == null) {
            return y;
        }

        var lyric = rawLyric as Lang.String;
        if (lyric.length() == 0) {
            return y;
        }

        var font = Graphics.FONT_XTINY;
        var maxWidth = 210;

        if (dc.getTextWidthInPixels(lyric, font) <= maxWidth) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, y, font, lyric, Graphics.TEXT_JUSTIFY_CENTER);
            return y + 20;
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
            return y + 20;
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
        dc.drawText(195, y + 20, font, line2, Graphics.TEXT_JUSTIFY_CENTER);
        return y + 40;
    }
}