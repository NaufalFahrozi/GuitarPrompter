import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

typedef SongStep as {
    :section as Lang.String,
    :chord as Lang.String,
    :lyric as Lang.String
};

typedef SongData as {
    :title as Lang.String,
    :artist as Lang.String,
    :steps as Lang.Array<SongStep>
};

(:typecheck(false))
class SongModel {
    private var mCurrentSongIndex as Lang.Number = 0;
    private var mCurrentStepIndex as Lang.Number = 0;
    private var mSongs as Lang.Array<SongData> = [];
    private var mStatusMessage as Lang.String? = null;

    // Hands-free Auto-Scroll Timer (default interval 3.5 detik)
    private var mAutoScrollTimer as Timer.Timer? = null;
    private var mIsAutoScrolling as Lang.Boolean = false;
    private var mScrollIntervalMs as Lang.Number = 3500;

    // Ganti URL ini dengan URL Raw Gist / Pastebin milikmu sendiri jika ingin sync lagu baru
    private var mSyncUrl as Lang.String = "https://gist.githubusercontent.com/raw/sample_songs.txt";

    public function initialize() {
        var loaded = Storage.getValue("SAVED_SONGS") as Lang.Array<SongData>?;

        if (loaded != null && loaded.size() > 0) {
            mSongs = loaded;
        } else {
            loadDefaultSongs();
        }
    }

    private function loadDefaultSongs() as Void {
        mSongs = [
            // Lagu 1
            {
                :title => "Country Roads",
                :artist => "John Denver",
                :steps => [
                    { :section => "Verse 1", :chord => "G",  :lyric => "Almost heaven, West Virginia" },
                    { :section => "Verse 1", :chord => "Em", :lyric => "Blue Ridge Mountains, Shenandoah" },
                    { :section => "Verse 1", :chord => "G",  :lyric => "Life is old there, older than trees" },
                    { :section => "Verse 1", :chord => "D",  :lyric => "Younger than mountains," },
                    { :section => "Verse 1", :chord => "C",  :lyric => "Growin' like a breeze" },
                    { :section => "Chorus",  :chord => "G",  :lyric => "Country roads, take me home" },
                    { :section => "Chorus",  :chord => "D",  :lyric => "To the place I belong" },
                    { :section => "Chorus",  :chord => "Em", :lyric => "West Virginia, mountain mama" },
                    { :section => "Chorus",  :chord => "C",  :lyric => "Take me home, country roads" }
                ]
            },
            // Lagu 2
            {
                :title => "Hold Your Hand",
                :artist => "The Beatles",
                :steps => [
                    { :section => "Verse 1", :chord => "G",  :lyric => "Oh yeah, I'll tell you somethin'" },
                    { :section => "Verse 1", :chord => "D",  :lyric => "I think you'll understand" },
                    { :section => "Verse 1", :chord => "G",  :lyric => "When I say that somethin'" },
                    { :section => "Verse 1", :chord => "Em", :lyric => "I wanna hold your hand" },
                    { :section => "Chorus",  :chord => "C",  :lyric => "I wanna hold your..." },
                    { :section => "Chorus",  :chord => "D",  :lyric => "HAND!" },
                    { :section => "Chorus",  :chord => "G",  :lyric => "I wanna hold your hand!" }
                ]
            }
        ];
    }

    // Auto-Scroll methods
    public function isAutoScrolling() as Lang.Boolean {
        return mIsAutoScrolling;
    }

    public function toggleAutoScroll() as Void {
        if (mIsAutoScrolling) {
            stopAutoScroll();
        } else {
            startAutoScroll();
        }
    }

    public function startAutoScroll() as Void {
        if (mAutoScrollTimer == null) {
            mAutoScrollTimer = new Timer.Timer();
        }
        mAutoScrollTimer.start(method(:onAutoScrollTimer), mScrollIntervalMs, true);
        mIsAutoScrolling = true;
        WatchUi.requestUpdate();
    }

    public function stopAutoScroll() as Void {
        if (mAutoScrollTimer != null) {
            mAutoScrollTimer.stop();
        }
        mIsAutoScrolling = false;
        WatchUi.requestUpdate();
    }

    public function onAutoScrollTimer() as Void {
        var currentSteps = mSongs[mCurrentSongIndex][:steps];
        if (mCurrentStepIndex < currentSteps.size() - 1) {
            mCurrentStepIndex++;
            mStatusMessage = null;
            WatchUi.requestUpdate();
        } else {
            stopAutoScroll();
        }
    }

    public function startSync() as Void {
        mStatusMessage = "Mengunduh Lagu...";
        WatchUi.requestUpdate();

        Communications.makeWebRequest(
            mSyncUrl,
            null,
            {
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN
            },
            method(:onSyncReceive)
        );
    }

    public function onSyncReceive(responseCode as Lang.Number, data as Lang.Dictionary or Lang.String or Null) as Void {
        if (responseCode == 200 && data instanceof Lang.String) {
            var parsedSongs = parseChordProText(data);
            if (parsedSongs.size() > 0) {
                mSongs = parsedSongs;
                mCurrentSongIndex = 0;
                mCurrentStepIndex = 0;
                Storage.setValue("SAVED_SONGS", mSongs as Application.Storage.ValueType);
                mStatusMessage = "Berhasil (" + mSongs.size().toString() + " Lagu)";
            } else {
                mStatusMessage = "Gagal: Format Salah";
            }
        } else {
            mStatusMessage = "Koneksi Gagal (" + responseCode.toString() + ")";
        }
        WatchUi.requestUpdate();
    }

    private function parseChordProText(rawText as Lang.String) as Lang.Array<SongData> {
        var result = [] as Lang.Array<SongData>;
        var currentSongTitle = "";
        var currentSteps = [] as Lang.Array<SongStep>;

        var remaining = rawText;
        while (remaining.length() > 0) {
            var nl = remaining.find("\n");
            var line = "";
            if (nl != null) {
                line = remaining.substring(0, nl);
                remaining = remaining.substring(nl + 1, remaining.length());
            } else {
                line = remaining;
                remaining = "";
            }

            if (line.length() > 0 && line.substring(line.length() - 1, line.length()).equals("\r")) {
                line = line.substring(0, line.length() - 1);
            }

            if (line.length() > 1 && line.substring(0, 1).equals("#")) {
                if (currentSongTitle.length() > 0 && currentSteps.size() > 0) {
                    result.add({
                        :title => currentSongTitle,
                        :artist => "Web",
                        :steps => currentSteps
                    });
                    currentSteps = [] as Lang.Array<SongStep>;
                }
                currentSongTitle = line.substring(1, line.length());
                while (currentSongTitle.length() > 0 && currentSongTitle.substring(0, 1).equals(" ")) {
                    currentSongTitle = currentSongTitle.substring(1, currentSongTitle.length());
                }
            } else if (line.find("[") != null && line.find("]") != null) {
                var openB = line.find("[") as Lang.Number;
                var closeB = line.find("]") as Lang.Number;
                if (closeB > openB) {
                    var chord = line.substring(openB + 1, closeB);
                    var lyric = line.substring(closeB + 1, line.length());
                    while (lyric.length() > 0 && lyric.substring(0, 1).equals(" ")) {
                        lyric = lyric.substring(1, lyric.length());
                    }
                    currentSteps.add({
                        :section => "Play",
                        :chord => chord,
                        :lyric => lyric
                    });
                }
            }
        }

        if (currentSongTitle.length() > 0 && currentSteps.size() > 0) {
            result.add({
                :title => currentSongTitle,
                :artist => "Web",
                :steps => currentSteps
            });
        }
        return result;
    }

    public function getSongCount() as Lang.Number {
        return mSongs.size();
    }

    public function getSongTitle(index as Lang.Number) as Lang.String {
        return mSongs[index][:title];
    }

    public function selectSong(index as Lang.Number) as Void {
        if (index >= 0 && index < mSongs.size()) {
            mCurrentSongIndex = index;
            mCurrentStepIndex = 0;
            mStatusMessage = null;
        }
    }

    public function getCurrentStep() as {
        :songTitle as Lang.String,
        :section as Lang.String,
        :chord as Lang.String,
        :lyric as Lang.String
    } {
        var song = mSongs[mCurrentSongIndex];
        var step = song[:steps][mCurrentStepIndex];
        return {
            :songTitle => song[:title],
            :section => step[:section],
            :chord => step[:chord],
            :lyric => step[:lyric]
        };
    }

    public function getPrevChord() as Lang.String {
        var currentSteps = mSongs[mCurrentSongIndex][:steps];
        if (mCurrentStepIndex > 0 && currentSteps.size() > 0) {
            return currentSteps[mCurrentStepIndex - 1][:chord];
        }
        return "--";
    }

    public function getCurrentChord() as Lang.String {
        var currentSteps = mSongs[mCurrentSongIndex][:steps];
        if (mCurrentStepIndex >= 0 && mCurrentStepIndex < currentSteps.size()) {
            return currentSteps[mCurrentStepIndex][:chord];
        }
        return "--";
    }

    public function getNextChord() as Lang.String {
        var currentSteps = mSongs[mCurrentSongIndex][:steps];
        if (mCurrentStepIndex + 1 < currentSteps.size()) {
            return currentSteps[mCurrentStepIndex + 1][:chord];
        }
        return "--";
    }

    public function getCurrentIndex() as Lang.Number { return mCurrentStepIndex; }
    public function getTotalSteps() as Lang.Number { return mSongs[mCurrentSongIndex][:steps].size(); }
    public function getStatusMessage() as Lang.String? { return mStatusMessage; }

    public function getProgressRatio() as Lang.Float {
        var size = mSongs[mCurrentSongIndex][:steps].size();
        return (size <= 1) ? 1.0f : (mCurrentStepIndex.toFloat() / (size - 1).toFloat());
    }

    public function nextStep() as Void {
        if (mCurrentStepIndex < mSongs[mCurrentSongIndex][:steps].size() - 1) {
            mCurrentStepIndex++;
            mStatusMessage = null;
        }
    }

    public function prevStep() as Void {
        if (mCurrentStepIndex > 0) {
            mCurrentStepIndex--;
            mStatusMessage = null;
        }
    }
}