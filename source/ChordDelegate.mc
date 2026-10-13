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
        return true;
    }

    public function onPreviousPage() as Lang.Boolean {
        mModel.prevStep();
        return true;
    }

    // Start/Enter button (top right): opens prompter control menu
    public function onSelect() as Lang.Boolean {
        var menu = new WatchUi.Menu2({:title => "Controls"});

        // 1. Play / Pause Auto-Scroll
        var autoTitle = mModel.isAutoScrolling() ? "Auto-Scroll: ON" : "Auto-Scroll: OFF";
        menu.addItem(new WatchUi.MenuItem(autoTitle, null, "AUTO_SCROLL", null));

        // 2. Playback Speed Multiplier (Practice Mode)
        var speedText = mModel.getSpeedMultiplier().format("%.1f") + "x";
        menu.addItem(new WatchUi.MenuItem("Speed: " + speedText, null, "SPEED", null));

        // 3. Tactile Haptic Vibration Toggle
        var hapticText = mModel.isHapticEnabled() ? "ON" : "OFF";
        menu.addItem(new WatchUi.MenuItem("Haptic: " + hapticText, null, "HAPTIC", null));

        // 4. Quick Restart Song
        menu.addItem(new WatchUi.MenuItem("Restart Song", null, "RESTART", null));

        // 5. Song Picker
        for (var i = 0; i < mModel.getSongCount(); i++) {
            var songTitle = mModel.getSongTitle(i);
            var songCapo = mModel.getSongCapo(i);
            var itemText = (songCapo != null) ? (songTitle + " [" + songCapo + "]") : songTitle;
            menu.addItem(new WatchUi.MenuItem(itemText, null, i, null));
        }

        // 6. Web Sync & Reset Defaults
        menu.addItem(new WatchUi.MenuItem("Sync from Web", null, "SYNC", null));
        menu.addItem(new WatchUi.MenuItem("Reset Defaults", null, "RESET", null));

        WatchUi.pushView(menu, new SongMenuDelegate(mModel), WatchUi.SLIDE_UP);
        return true;
    }

    public function onBack() as Lang.Boolean {
        return false;
    }

    // Touch controls: Center zone (80-160) = toggle auto-scroll, Bottom (>160) = next, Top (<80) = prev
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
        return true;
    }

    // Natural AMOLED swipe gestures: Left/Up = Next Chord, Right/Down = Prev Chord
    public function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Lang.Boolean {
        var dir = swipeEvent.getDirection();
        if (dir == WatchUi.SWIPE_LEFT || dir == WatchUi.SWIPE_UP) {
            return onNextPage();
        } else if (dir == WatchUi.SWIPE_RIGHT || dir == WatchUi.SWIPE_DOWN) {
            return onPreviousPage();
        }
        return false;
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
            } else if (id.equals("SPEED")) {
                mModel.cycleSpeed();
                WatchUi.popView(WatchUi.SLIDE_DOWN);
            } else if (id.equals("HAPTIC")) {
                mModel.toggleHaptic();
                WatchUi.popView(WatchUi.SLIDE_DOWN);
            } else if (id.equals("RESTART")) {
                mModel.restartSong();
                WatchUi.popView(WatchUi.SLIDE_DOWN);
            } else if (id.equals("SYNC")) {
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                mModel.startSync();
            } else if (id.equals("RESET")) {
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                mModel.resetToDefaultSongs();
            }
        }
    }

    public function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}