import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

typedef SongStep as {
    :section as Lang.String,
    :chord as Lang.String,
    :lyric as Lang.String,
    :durationMs as Lang.Number?
};

typedef SongData as {
    :title as Lang.String,
    :artist as Lang.String,
    :steps as Lang.Array<SongStep>,
    :defaultDurationMs as Lang.Number?
};

(:typecheck(false))
class SongModel {
    private var mCurrentSongIndex as Lang.Number = 0;
    private var mCurrentStepIndex as Lang.Number = 0;
    private var mSongs as Lang.Array<SongData> = [];
    private var mStatusMessage as Lang.String? = null;

    // Hands-free auto-scroll timer (dynamic per-chord duration, default 3.5s)
    private var mAutoScrollTimer as Timer.Timer? = null;
    private var mIsAutoScrolling as Lang.Boolean = false;
    private var mScrollIntervalMs as Lang.Number = 3500;

    // Change this URL to your own raw Gist or Pastebin URL to sync custom songs
    private var mSyncUrl as Lang.String = "https://gist.githubusercontent.com/raw/sample_songs.txt";

    public function initialize() {
        var loaded = Storage.getValue("SAVED_SONGS") as Lang.Array<SongData>?;

        if (loaded != null && loaded.size() > 0) {
            mSongs = loaded;
        } else {
            loadDefaultSongs();
        }
    }

    public function resetToDefaultSongs() as Void {
        Storage.deleteValue("SAVED_SONGS");
        loadDefaultSongs();
        mCurrentSongIndex = 0;
        mCurrentStepIndex = 0;
        mStatusMessage = "Default songs loaded";
        WatchUi.requestUpdate();
    }

    private function loadDefaultSongs() as Void {
        mSongs = [
            // Song 1: Take Me Home, Country Roads - John Denver (~82 BPM)
            {
                :title => "Country Roads",
                :artist => "John Denver",
                :defaultDurationMs => 3000,
                :steps => [
                    { :section => "Verse 1", :chord => "G",  :lyric => "Almost heaven, West Virginia", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "Em", :lyric => "Blue Ridge Mountains, Shenandoah", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "G",  :lyric => "Life is old there, older than trees", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "D",  :lyric => "Younger than the mountains,", :durationMs => 2500 },
                    { :section => "Verse 1", :chord => "C",  :lyric => "Growin' like a breeze", :durationMs => 2500 },
                    { :section => "Chorus",  :chord => "G",  :lyric => "Country roads, take me home", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "D",  :lyric => "To the place I belong", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Em", :lyric => "West Virginia, mountain mama", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "C",  :lyric => "Take me home, country roads", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "G",  :lyric => "All my memories gather 'round her", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "Em", :lyric => "Miner's lady, stranger to blue water", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "G",  :lyric => "Dark and dusty, painted on the sky", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "D",  :lyric => "Misty taste of moonshine,", :durationMs => 2500 },
                    { :section => "Verse 2", :chord => "C",  :lyric => "Teardrop in my eye", :durationMs => 2500 },
                    { :section => "Chorus",  :chord => "G",  :lyric => "Country roads, take me home", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "D",  :lyric => "To the place I belong", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Em", :lyric => "West Virginia, mountain mama", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "C",  :lyric => "Take me home, country roads", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "G",  :lyric => "Take me home, country roads", :durationMs => 3000 }
                ]
            },
            // Song 2: Creep - Radiohead (~92 BPM, G - B - C - Cm progression)
            {
                :title => "Creep",
                :artist => "Radiohead",
                :defaultDurationMs => 5200,
                :steps => [
                    { :section => "Verse 1", :chord => "G",  :lyric => "When you were here before", :durationMs => 5200 },
                    { :section => "Verse 1", :chord => "B",  :lyric => "Couldn't look you in the eye", :durationMs => 5200 },
                    { :section => "Verse 1", :chord => "C",  :lyric => "You're just like an angel", :durationMs => 5200 },
                    { :section => "Verse 1", :chord => "Cm", :lyric => "Your skin makes me cry", :durationMs => 5200 },
                    { :section => "Verse 2", :chord => "G",  :lyric => "You float like a feather", :durationMs => 5200 },
                    { :section => "Verse 2", :chord => "B",  :lyric => "In a beautiful world", :durationMs => 5200 },
                    { :section => "Verse 2", :chord => "C",  :lyric => "I wish I was special", :durationMs => 5200 },
                    { :section => "Verse 2", :chord => "Cm", :lyric => "You're so very special", :durationMs => 5200 },
                    { :section => "Chorus",  :chord => "G",  :lyric => "But I'm a creep, I'm a weirdo", :durationMs => 5200 },
                    { :section => "Chorus",  :chord => "B",  :lyric => "What the hell am I doin' here?", :durationMs => 5200 },
                    { :section => "Chorus",  :chord => "C",  :lyric => "I don't belong here", :durationMs => 5200 },
                    { :section => "Chorus",  :chord => "Cm", :lyric => "I don't care if it hurts", :durationMs => 5200 },
                    { :section => "Outro",   :chord => "G",  :lyric => "Whatever makes you happy", :durationMs => 5200 },
                    { :section => "Outro",   :chord => "B",  :lyric => "Whatever you want", :durationMs => 5200 },
                    { :section => "Outro",   :chord => "C",  :lyric => "You're so very special...", :durationMs => 5200 },
                    { :section => "Outro",   :chord => "Cm", :lyric => "I don't belong here...", :durationMs => 5200 }
                ]
            },
            // Song 3: Hey Jude - The Beatles (~74 BPM)
            {
                :title => "Hey Jude",
                :artist => "The Beatles",
                :defaultDurationMs => 3300,
                :steps => [
                    { :section => "Verse 1", :chord => "F",  :lyric => "Hey Jude, don't make it bad", :durationMs => 3300 },
                    { :section => "Verse 1", :chord => "C",  :lyric => "Take a sad song and make it better", :durationMs => 3300 },
                    { :section => "Verse 1", :chord => "C7", :lyric => "Remember to let her into your heart", :durationMs => 3300 },
                    { :section => "Verse 1", :chord => "F",  :lyric => "Then you can start to make it better", :durationMs => 3300 },
                    { :section => "Verse 2", :chord => "F",  :lyric => "Hey Jude, don't be afraid", :durationMs => 3300 },
                    { :section => "Verse 2", :chord => "C",  :lyric => "You were made to go out and get her", :durationMs => 3300 },
                    { :section => "Verse 2", :chord => "C7", :lyric => "The minute you let her under your skin", :durationMs => 3300 },
                    { :section => "Verse 2", :chord => "F",  :lyric => "Then you begin to make it better", :durationMs => 3300 },
                    { :section => "Chorus",  :chord => "Bb", :lyric => "And anytime you feel the pain", :durationMs => 3300 },
                    { :section => "Chorus",  :chord => "F",  :lyric => "Hey Jude, refrain", :durationMs => 3300 },
                    { :section => "Chorus",  :chord => "C",  :lyric => "Don't carry the world upon your shoulders", :durationMs => 3300 },
                    { :section => "Chorus",  :chord => "F",  :lyric => "For well you know that it's a fool", :durationMs => 3300 },
                    { :section => "Outro",   :chord => "F",  :lyric => "Na, na na na na na na", :durationMs => 3300 },
                    { :section => "Outro",   :chord => "Eb", :lyric => "Na na na na,", :durationMs => 3300 },
                    { :section => "Outro",   :chord => "Bb", :lyric => "Hey Jude", :durationMs => 3300 },
                    { :section => "Outro",   :chord => "F",  :lyric => "Jude, Jude, Jude...", :durationMs => 3300 }
                ]
            }
        ];
    }

    // Auto-scroll methods with dynamic per-chord scheduling
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
        mIsAutoScrolling = true;
        scheduleNextStepTimer();
        WatchUi.requestUpdate();
    }

    public function stopAutoScroll() as Void {
        if (mAutoScrollTimer != null) {
            mAutoScrollTimer.stop();
        }
        mIsAutoScrolling = false;
        WatchUi.requestUpdate();
    }

    private function scheduleNextStepTimer() as Void {
        if (!mIsAutoScrolling) {
            return;
        }
        var song = mSongs[mCurrentSongIndex];
        var steps = song[:steps];
        if (mCurrentStepIndex >= steps.size()) {
            stopAutoScroll();
            return;
        }

        var step = steps[mCurrentStepIndex];
        var duration = mScrollIntervalMs;
        if (step.hasKey(:durationMs) && step[:durationMs] != null) {
            duration = step[:durationMs] as Lang.Number;
        } else if (song.hasKey(:defaultDurationMs) && song[:defaultDurationMs] != null) {
            duration = song[:defaultDurationMs] as Lang.Number;
        }

        if (mAutoScrollTimer == null) {
            mAutoScrollTimer = new Timer.Timer();
        }
        // One-shot timer chained to the exact duration of current step
        mAutoScrollTimer.start(method(:onAutoScrollTimer), duration, false);
    }

    public function onAutoScrollTimer() as Void {
        if (!mIsAutoScrolling) {
            return;
        }
        var currentSteps = mSongs[mCurrentSongIndex][:steps];
        if (mCurrentStepIndex < currentSteps.size() - 1) {
            mCurrentStepIndex++;
            mStatusMessage = null;
            WatchUi.requestUpdate();
            scheduleNextStepTimer();
        } else {
            stopAutoScroll();
        }
    }

    public function startSync() as Void {
        mStatusMessage = "Downloading songs...";
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
                mStatusMessage = "Success (" + mSongs.size().toString() + " Songs)";
            } else {
                mStatusMessage = "Failed: Invalid format";
            }
        } else {
            mStatusMessage = "Connection failed (" + responseCode.toString() + ")";
        }
        WatchUi.requestUpdate();
    }

    // Parses ChordPro text with optional durations: [Chord] or [Chord:Seconds]
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
                        :steps => currentSteps,
                        :defaultDurationMs => 3500
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
                    var rawChord = line.substring(openB + 1, closeB);
                    var chord = rawChord;
                    var durationMs = null as Lang.Number?;

                    var colonIdx = rawChord.find(":");
                    if (colonIdx != null) {
                        var colNum = colonIdx as Lang.Number;
                        chord = rawChord.substring(0, colNum);
                        if (colNum + 1 < rawChord.length()) {
                            var durStr = rawChord.substring(colNum + 1, rawChord.length());
                            var durFloat = durStr.toFloat();
                            if (durFloat != null && durFloat > 0.0f) {
                                if (durFloat < 60.0f) {
                                    durationMs = (durFloat * 1000.0f).toNumber();
                                } else {
                                    durationMs = durFloat.toNumber();
                                }
                            }
                        }
                    }

                    var lyric = line.substring(closeB + 1, line.length());
                    while (lyric.length() > 0 && lyric.substring(0, 1).equals(" ")) {
                        lyric = lyric.substring(1, lyric.length());
                    }
                    currentSteps.add({
                        :section => "Play",
                        :chord => chord,
                        :lyric => lyric,
                        :durationMs => durationMs
                    });
                }
            }
        }

        if (currentSongTitle.length() > 0 && currentSteps.size() > 0) {
            result.add({
                :title => currentSongTitle,
                :artist => "Web",
                :steps => currentSteps,
                :defaultDurationMs => 3500
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
            if (mIsAutoScrolling) {
                scheduleNextStepTimer();
            }
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
            if (mIsAutoScrolling) {
                scheduleNextStepTimer();
            }
        }
    }

    public function prevStep() as Void {
        if (mCurrentStepIndex > 0) {
            mCurrentStepIndex--;
            mStatusMessage = null;
            if (mIsAutoScrolling) {
                scheduleNextStepTimer();
            }
        }
    }
}