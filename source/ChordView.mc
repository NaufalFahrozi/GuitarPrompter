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
            dc.drawText(195, 195, Graphics.FONT_MEDIUM, statusMsg, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        var step = mModel.getCurrentStep();
        var currentStepNum = mModel.getCurrentIndex() + 1;
        var totalSteps = mModel.getTotalSteps();
        var capo = mModel.getCurrentCapo();
        var isAuto = mModel.isAutoScrolling();
        var speed = mModel.getSpeedMultiplier();

        // 1. Top status pill: [▶ AUTO 1.0x] or [❚❚ MANUAL]
        if (isAuto) {
            dc.setColor(0x072A12, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(135, 20, 120, 18, 9);
            dc.setColor(0x00E676, Graphics.COLOR_TRANSPARENT);
            dc.drawRoundedRectangle(135, 20, 120, 18, 9);
            dc.setColor(0x00FF7F, Graphics.COLOR_TRANSPARENT);
            var speedBadge = (speed == 1.0f) ? "[▶ AUTO]" : Lang.format("[▶ $1$x]", [speed.format("%.1f")]);
            dc.drawText(195, 20, Graphics.FONT_XTINY, speedBadge, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(0x1A1A1A, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(140, 20, 110, 18, 9);
            dc.setColor(0x444444, Graphics.COLOR_TRANSPARENT);
            dc.drawRoundedRectangle(140, 20, 110, 18, 9);
            dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 20, Graphics.FONT_XTINY, "[❚❚ MANUAL]", Graphics.TEXT_JUSTIFY_CENTER);
        }

        // 2. Top header: Song Title & optional Capo Badge
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 42, Graphics.FONT_XTINY, step[:songTitle], Graphics.TEXT_JUSTIFY_CENTER);

        var dividerY = 94;
        if (capo != null) {
            // Neon cyan pill badge for capo tuning requirement
            var capoStr = "[" + (capo as Lang.String).toUpper() + "]";
            dc.setColor(0x00E5FF, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 60, Graphics.FONT_XTINY, capoStr, Graphics.TEXT_JUSTIFY_CENTER);

            // Section & step position
            var statusLine = Lang.format("$1$  •  $2$/$3$", [step[:section], currentStepNum, totalSteps]);
            dc.setColor(0xFFA500, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 78, Graphics.FONT_XTINY, statusLine, Graphics.TEXT_JUSTIFY_CENTER);
            dividerY = 98;
        } else {
            // Standard tuning: section line directly below title
            var statusLine = Lang.format("$1$  •  $2$/$3$", [step[:section], currentStepNum, totalSteps]);
            dc.setColor(0xFFA500, Graphics.COLOR_TRANSPARENT);
            dc.drawText(195, 64, Graphics.FONT_XTINY, statusLine, Graphics.TEXT_JUSTIFY_CENTER);
            dividerY = 88;
        }

        // Top divider
        dc.setColor(0x282828, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(95, dividerY, 295, dividerY);

        // 3. Middle Stage: 3-Chord Horizontal Display
        var prevChord = mModel.getPrevChord();
        var currentChord = mModel.getCurrentChord();
        var nextChord = mModel.getNextChord();

        // Previous chord (left: muted soft gray)
        dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
        dc.drawText(75, 144, Graphics.FONT_MEDIUM, prevChord, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Current chord card (center: warm dark amber backdrop with glowing electric orange border)
        dc.setColor(0x221303, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(135, 112, 120, 64, 10);

        dc.setColor(0xFF7700, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawRoundedRectangle(135, 112, 120, 64, 10);
        dc.setPenWidth(1);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 144, Graphics.FONT_SYSTEM_LARGE, currentChord, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Next chord (right: soft ice-cyan accent)
        dc.setColor(0x80CBC4, Graphics.COLOR_TRANSPARENT);
        dc.drawText(315, 144, Graphics.FONT_MEDIUM, nextChord, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Stage bottom divider
        dc.setColor(0x282828, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(90, 192, 300, 192);

        // 4. Lyric area (wrapped cleanly into 2 lines)
        drawWrappedLyric(dc, step[:lyric] as Lang.String?, 228);

        // Next chord teaser hint
        var nextHint = (nextChord.equals("--")) ? "• End of Song •" : "Next: " + nextChord;
        dc.setColor(0x777777, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 276, Graphics.FONT_XTINY, nextHint, Graphics.TEXT_JUSTIFY_CENTER);

        // 5. Sleek bottom progress bar and step percentage
        dc.setColor(0x202020, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(115, 318, 160, 6, 3);

        var fillW = (160.0f * mModel.getProgressRatio()).toNumber();
        if (fillW > 0) {
            dc.setColor(0xFF7700, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(115, 318, fillW, 6, 3);
        }

        var percent = (mModel.getProgressRatio() * 100.0f).toNumber();
        var progText = Lang.format("Step $1$/$2$ ($3$%)", [currentStepNum, totalSteps, percent]);
        dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 336, Graphics.FONT_XTINY, progText, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Split long lyrics across 2 lines to fit circular 390x390 display without edge-clipping
    private function drawWrappedLyric(dc as Graphics.Dc, rawLyric as Lang.String?, y as Lang.Number) as Void {
        if (rawLyric == null) {
            return;
        }

        var lyric = rawLyric as Lang.String;
        if (lyric.length() == 0) {
            return;
        }

        var font = Graphics.FONT_SMALL;
        var maxWidth = 265;

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
        dc.drawText(195, y - 14, font, line1, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(195, y + 14, font, line2, Graphics.TEXT_JUSTIFY_CENTER);
    }
}