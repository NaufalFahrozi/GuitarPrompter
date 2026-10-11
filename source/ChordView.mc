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

        // 1. Bagian Atas: Judul Lagu & Nomor Step
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 50, Graphics.FONT_XTINY, step[:songTitle], Graphics.TEXT_JUSTIFY_CENTER);

        var statusLine = Lang.format("$1$  •  $2$/$3$", [step[:section], currentStepNum, totalSteps]);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 74, Graphics.FONT_XTINY, statusLine, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(0x2A2A2A, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(120, 100, 270, 100);

        // 2. Bagian Tengah: Kunci Gitar Besar Berwarna Oranye Cerah
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 155, Graphics.FONT_SYSTEM_LARGE, step[:chord], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(0x2A2A2A, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(90, 208, 300, 208);

        // 3. Bagian Bawah: Lirik Aktif & Petunjuk Kunci Selanjutnya
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 234, Graphics.FONT_SMALL, step[:lyric], Graphics.TEXT_JUSTIFY_CENTER);

        var nextChord = mModel.getNextChord();
        var nextHint = (nextChord.equals("--")) ? "Selesai" : "Berikutnya: " + nextChord;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(195, 280, Graphics.FONT_XTINY, nextHint, Graphics.TEXT_JUSTIFY_CENTER);

        // 4. Garis Progres Lagu
        dc.setColor(0x222222, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(135, 330, 120, 4, 2);

        var fillW = (120.0f * mModel.getProgressRatio()).toNumber();
        if (fillW > 0) {
            dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(135, 330, fillW, 4, 2);
        }
    }
}