import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

(:typecheck(strict))
class GuitarPrompterApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Lang.Dictionary?) as Void {
    }

    function onStop(state as Lang.Dictionary?) as Void {
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        var model = new SongModel();
        var view = new ChordView(model);
        var delegate = new ChordDelegate(model);
        return [view, delegate];
    }
}

function getApp() as GuitarPrompterApp {
    return Application.getApp() as GuitarPrompterApp;
}