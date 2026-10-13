import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

(:typecheck(strict))
class ChordDelegate extends WatchUi.BehaviorDelegate {
    private var mModel as SongModel;

    public function initialize(model as SongModel) {
        BehaviorDelegate.initialize();
        mModel = model;
    }

    public function onNextPage() as Lang.Boolean {
        mModel.nextStep();
        WatchUi.requestUpdate();
        return true;
    }

    public function onPreviousPage() as Lang.Boolean {
        mModel.prevStep();
        WatchUi.requestUpdate();
        return true;
    }

    // Tombol Start/Enter (Kanan Atas) membuka menu: Play/Pause Auto-Scroll, daftar lagu, dan Sync
    public function onSelect() as Lang.Boolean {
        var menu = new WatchUi.Menu2({:title => "Menu"});

        var autoTitle = mModel.isAutoScrolling() ? "Pause Auto-Scroll" : "Play Auto-Scroll";
        var autoSub = mModel.isAutoScrolling() ? "Hentikan gulir otomatis" : "Gulir otomatis (3.5s)";
        menu.addItem(new WatchUi.MenuItem(autoTitle, autoSub, "AUTO_SCROLL", null));

        for (var i = 0; i < mModel.getSongCount(); i++) {
            menu.addItem(new WatchUi.MenuItem(mModel.getSongTitle(i), null, i, null));
        }
        menu.addItem(new WatchUi.MenuItem("🔄 Sync dari Web", "Download lirik baru", "SYNC", null));

        WatchUi.pushView(menu, new SongMenuDelegate(mModel), WatchUi.SLIDE_UP);
        return true;
    }

    public function onBack() as Lang.Boolean {
        return false;
    }

    // Sentuhan Layar: Tengah (80-160) = Toggle Auto-Scroll, Bawah (>160) = Maju, Atas (<80) = Mundur
    public function onTap(clickEvent as WatchUi.ClickEvent) as Lang.Boolean {
        var coords = clickEvent.getCoordinates();
        var y = coords[1];
        if (y >= 80 && y <= 160) {
            mModel.toggleAutoScroll();
        } else if (y > 160) {
            mModel.nextStep();
        } else {
            mModel.prevStep();
        }
        WatchUi.requestUpdate();
        return true;
    }

    public function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_DOWN) {
            return onNextPage();
        } else if (key == WatchUi.KEY_UP) {
            return onPreviousPage();
        } else if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            return onSelect();
        } else if (key == WatchUi.KEY_ESC) {
            return onBack();
        }
        return false;
    }
}

(:typecheck(strict))
class SongMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var mModel as SongModel;

    public function initialize(model as SongModel) {
        Menu2InputDelegate.initialize();
        mModel = model;
    }

    public function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id instanceof Lang.Number) {
            mModel.selectSong(id);
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if (id instanceof Lang.String) {
            if (id.equals("AUTO_SCROLL")) {
                mModel.toggleAutoScroll();
                WatchUi.popView(WatchUi.SLIDE_DOWN);
            } else if (id.equals("SYNC")) {
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                mModel.startSync();
            }
        }
    }

    public function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}