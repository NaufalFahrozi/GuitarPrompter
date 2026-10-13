import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Attention;
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
    :capo as Lang.String?,
    :steps as Lang.Array<SongStep>,
    :defaultDurationMs as Lang.Number?
};

(:typecheck(false))
class SongModel {
    private var mCurrentSongIndex as Lang.Number = 0;
    private var mCurrentStepIndex as Lang.Number = 0;
    private var mSongs as Lang.Array<SongData> = [];
    private var mStatusMessage as Lang.String? = null;

    // Hands-free dynamic auto-scroll timer
    private var mAutoScrollTimer as Timer.Timer? = null;
    private var mIsAutoScrolling as Lang.Boolean = false;
    private var mScrollIntervalMs as Lang.Number = 3500;

    // Tactile haptic feedback (wrist pulse on chord transitions)
    private var mHapticEnabled as Lang.Boolean = true;

    // Practice speed multiplier (0.8x slow practice, 1.0x normal, 1.2x fast, 1.5x up-tempo)
    private var mSpeedMultiplier as Lang.Float = 1.0f;

    // Raw GitHub URL for one-click Web Sync directly from repo
    private var mSyncUrl as Lang.String = "https://raw.githubusercontent.com/NaufalFahrozi/GuitarPrompter/main/songs.txt";

    public function initialize() {
        Storage.deleteValue("SAVED_SONGS"); // Clear legacy invalid symbol dictionary if present
        var savedRaw = Storage.getValue("SAVED_RAW_SONGS") as Lang.String?;
        if (savedRaw != null && savedRaw.length() > 0) {
            var parsed = parseChordProText(savedRaw);
            if (parsed.size() > 0) {
                mSongs = parsed;
            } else {
                loadDefaultSongs();
            }
        } else {
            loadDefaultSongs();
        }

        var savedHaptic = Storage.getValue("HAPTIC_ENABLED") as Lang.Boolean?;
        if (savedHaptic != null) {
            mHapticEnabled = savedHaptic;
        }

        var savedSpeed = Storage.getValue("SPEED_MULT") as Lang.Float?;
        if (savedSpeed != null) {
            mSpeedMultiplier = savedSpeed;
        }
    }

    public function resetToDefaultSongs() as Void {
        Storage.deleteValue("SAVED_SONGS");
        Storage.deleteValue("SAVED_RAW_SONGS");
        loadDefaultSongs();
        mCurrentSongIndex = 0;
        mCurrentStepIndex = 0;
        mStatusMessage = "Default songs loaded";
        WatchUi.requestUpdate();
    }

    private function loadDefaultSongs() as Void {
        mSongs = [
            // 1. Take Me Home, Country Roads - John Denver (No Capo)
            {
                :title => "Country Roads",
                :artist => "John Denver",
                :capo => null,
                :defaultDurationMs => 3000,
                :steps => [
                    { :section => "Verse 1", :chord => "G",     :lyric => "Almost heaven, West Virginia", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "Em",    :lyric => "Blue Ridge Mountains, Shenandoah River", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "G",     :lyric => "Life is old there, older than the trees", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "D",     :lyric => "Younger than the mountains,", :durationMs => 2500 },
                    { :section => "Verse 1", :chord => "C",     :lyric => "Growin' like a breeze", :durationMs => 2000 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "Country roads, take me home", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "D",     :lyric => "To the place I belong", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Em",    :lyric => "West Virginia, mountain mama", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "C",     :lyric => "Take me home, country roads", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "G",     :lyric => "All my memories gather 'round her", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "Em",    :lyric => "Miner's lady, stranger to blue water", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "G",     :lyric => "Dark and dusty, painted on the sky", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "D",     :lyric => "Misty taste of moonshine,", :durationMs => 2500 },
                    { :section => "Verse 2", :chord => "C",     :lyric => "Teardrop in my eye", :durationMs => 2000 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "Country roads, take me home", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "D",     :lyric => "To the place I belong", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Em",    :lyric => "West Virginia, mountain mama", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "C",     :lyric => "Take me home, country roads", :durationMs => 3000 },
                    { :section => "Bridge",  :chord => "Em",    :lyric => "I hear her voice in the mornin' hour she calls me", :durationMs => 2500 },
                    { :section => "Bridge",  :chord => "D",     :lyric => "Radio reminds me of my home far away", :durationMs => 2500 },
                    { :section => "Bridge",  :chord => "G",     :lyric => "Drivin' down the road I get a feelin'", :durationMs => 2500 },
                    { :section => "Bridge",  :chord => "D",     :lyric => "That I should have been home", :durationMs => 2000 },
                    { :section => "Bridge",  :chord => "D7",    :lyric => "yesterday, yesterday", :durationMs => 2000 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "Country roads, take me home", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "D",     :lyric => "To the place I belong", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Em",    :lyric => "West Virginia, mountain mama", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "C",     :lyric => "Take me home, country roads", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "G",     :lyric => "Take me home, country roads", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "D",     :lyric => "Take me home, country roads", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "G",     :lyric => "Country roads", :durationMs => 3000 }
                ]
            },

            // 2. Hey Jude - The Beatles (Capo 3, Key of D)
            {
                :title => "Hey Jude",
                :artist => "The Beatles",
                :capo => "Capo 3",
                :defaultDurationMs => 3500,
                :steps => [
                    { :section => "Verse 1", :chord => "D",     :lyric => "Hey Jude, don't make it bad", :durationMs => 3500 },
                    { :section => "Verse 1", :chord => "A",     :lyric => "Take a sad song and make it better", :durationMs => 3500 },
                    { :section => "Verse 1", :chord => "G",     :lyric => "Remember to let her into your heart", :durationMs => 3500 },
                    { :section => "Verse 1", :chord => "D",     :lyric => "Then you can start to make it", :durationMs => 2500 },
                    { :section => "Verse 1", :chord => "A",     :lyric => "better", :durationMs => 2000 },
                    { :section => "Verse 2", :chord => "D",     :lyric => "Hey Jude, don't be afraid", :durationMs => 3500 },
                    { :section => "Verse 2", :chord => "A",     :lyric => "You were made to go out and get her", :durationMs => 3500 },
                    { :section => "Verse 2", :chord => "G",     :lyric => "The minute you let her under your skin", :durationMs => 3500 },
                    { :section => "Verse 2", :chord => "D",     :lyric => "Then you begin to make it", :durationMs => 2500 },
                    { :section => "Verse 2", :chord => "A",     :lyric => "better", :durationMs => 2000 },
                    { :section => "Chorus 1", :chord => "D7",   :lyric => "And anytime you feel the pain, refrain", :durationMs => 2500 },
                    { :section => "Chorus 1", :chord => "G",    :lyric => "Hey Jude, refrain", :durationMs => 2000 },
                    { :section => "Chorus 1", :chord => "Bm",   :lyric => "Don't carry the world upon", :durationMs => 2000 },
                    { :section => "Chorus 1", :chord => "Em",   :lyric => "your shoulders", :durationMs => 2000 },
                    { :section => "Chorus 1", :chord => "A",    :lyric => "For well you know that it's a fool", :durationMs => 2500 },
                    { :section => "Chorus 1", :chord => "D",    :lyric => "who plays it cool", :durationMs => 2500 },
                    { :section => "Chorus 1", :chord => "D7",   :lyric => "By making his world a little colder", :durationMs => 2500 },
                    { :section => "Interlude", :chord => "D",   :lyric => "Da da da da da", :durationMs => 2000 },
                    { :section => "Interlude", :chord => "D7",  :lyric => "da da da da", :durationMs => 2000 },
                    { :section => "Interlude", :chord => "A7",  :lyric => "da...", :durationMs => 2000 },
                    { :section => "Verse 3", :chord => "D",     :lyric => "Hey Jude, don't let me down", :durationMs => 3500 },
                    { :section => "Verse 3", :chord => "A",     :lyric => "You have found her, now go and get her", :durationMs => 3500 },
                    { :section => "Verse 3", :chord => "G",     :lyric => "Remember to let her into your heart", :durationMs => 3500 },
                    { :section => "Verse 3", :chord => "D",     :lyric => "Then you can start to make it", :durationMs => 2500 },
                    { :section => "Verse 3", :chord => "A",     :lyric => "better", :durationMs => 2000 },
                    { :section => "Chorus 2", :chord => "D7",   :lyric => "So let it out and let it in, begin", :durationMs => 2500 },
                    { :section => "Chorus 2", :chord => "G",    :lyric => "Hey Jude, begin", :durationMs => 2000 },
                    { :section => "Chorus 2", :chord => "Bm",   :lyric => "You're waiting for someone to", :durationMs => 2000 },
                    { :section => "Chorus 2", :chord => "Em",   :lyric => "perform with", :durationMs => 2000 },
                    { :section => "Chorus 2", :chord => "A",    :lyric => "And don't you know that it's just you", :durationMs => 2500 },
                    { :section => "Chorus 2", :chord => "D",    :lyric => "Hey Jude, you'll do", :durationMs => 2500 },
                    { :section => "Chorus 2", :chord => "D7",   :lyric => "The movement you need is on your shoulders", :durationMs => 2500 },
                    { :section => "Interlude", :chord => "D",   :lyric => "Da da da da da", :durationMs => 2000 },
                    { :section => "Interlude", :chord => "D7",  :lyric => "da da da da", :durationMs => 2000 },
                    { :section => "Interlude", :chord => "A7",  :lyric => "da...", :durationMs => 2000 },
                    { :section => "Verse 4", :chord => "D",     :lyric => "Hey Jude, don't make it bad", :durationMs => 3500 },
                    { :section => "Verse 4", :chord => "A",     :lyric => "Take a sad song and make it better", :durationMs => 3500 },
                    { :section => "Verse 4", :chord => "G",     :lyric => "Remember to let her under your skin", :durationMs => 3500 },
                    { :section => "Verse 4", :chord => "D",     :lyric => "Then you begin to make it", :durationMs => 2500 },
                    { :section => "Verse 4", :chord => "A",     :lyric => "better, better, better!", :durationMs => 2000 },
                    { :section => "Outro",   :chord => "D",     :lyric => "Na na na na na na na", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "C",     :lyric => "Na na na na,", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "G",     :lyric => "Hey Jude", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "D",     :lyric => "Na na na na na na na", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "C",     :lyric => "Na na na na,", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "G",     :lyric => "Hey Jude", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "D",     :lyric => "Na na na na na na na", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "C",     :lyric => "Na na na na,", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "G",     :lyric => "Hey Jude...", :durationMs => 3000 }
                ]
            },

            // 3. Here Comes The Sun - The Beatles (Capo 7, Key of D)
            {
                :title => "Here Comes The Sun",
                :artist => "The Beatles",
                :capo => "Capo 7",
                :defaultDurationMs => 3000,
                :steps => [
                    { :section => "Chorus",  :chord => "D",     :lyric => "Here comes the sun, doo-doo-doo-doo", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "Here comes the sun,", :durationMs => 2500 },
                    { :section => "Chorus",  :chord => "E7",    :lyric => "And I say, it's alright", :durationMs => 2000 },
                    { :section => "Chorus",  :chord => "A7",    :lyric => "It's alright", :durationMs => 2000 },
                    { :section => "Verse 1", :chord => "D",     :lyric => "Little darling, long cold lonely winter", :durationMs => 3500 },
                    { :section => "Verse 1", :chord => "G",     :lyric => "Little darling, feels like years since here", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "A7",    :lyric => "It's been here", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "D",     :lyric => "Here comes the sun, doo-doo-doo-doo", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "Here comes the sun, it's alright", :durationMs => 2500 },
                    { :section => "Chorus",  :chord => "E7",    :lyric => "It's alright", :durationMs => 2000 },
                    { :section => "Verse 2", :chord => "D",     :lyric => "Little darling, smiles returning to faces", :durationMs => 3500 },
                    { :section => "Verse 2", :chord => "G",     :lyric => "Little darling, seems like years since here", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "A7",    :lyric => "It's been here", :durationMs => 3000 },
                    { :section => "Bridge",  :chord => "C",     :lyric => "Sun, sun, sun, here it comes", :durationMs => 2000 },
                    { :section => "Bridge",  :chord => "G",     :lyric => "Sun, sun, sun, here it comes", :durationMs => 2000 },
                    { :section => "Bridge",  :chord => "D",     :lyric => "Sun, sun, sun, here it comes", :durationMs => 2000 },
                    { :section => "Bridge",  :chord => "A7",    :lyric => "Sun, sun, sun, here it comes", :durationMs => 2000 },
                    { :section => "Verse 3", :chord => "D",     :lyric => "Little darling, ice is slowly melting", :durationMs => 3500 },
                    { :section => "Verse 3", :chord => "G",     :lyric => "Little darling, seems like years since clear", :durationMs => 3000 },
                    { :section => "Verse 3", :chord => "A7",    :lyric => "It's been clear", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "D",     :lyric => "Here comes the sun, doo-doo-doo-doo", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "Here comes the sun, and I say", :durationMs => 2500 },
                    { :section => "Chorus",  :chord => "E7",    :lyric => "It's alright", :durationMs => 2000 },
                    { :section => "Outro",   :chord => "D",     :lyric => "It's alright, it's alright", :durationMs => 3000 }
                ]
            },

            // 4. Creep - Radiohead (Capo 7: C - E - F - Fm)
            {
                :title => "Creep",
                :artist => "Radiohead",
                :capo => "Capo 7",
                :defaultDurationMs => 4800,
                :steps => [
                    // Intro
                    { :section => "Intro",   :chord => "C",  :lyric => "(Intro)", :durationMs => 4500 },
                    { :section => "Intro",   :chord => "E",  :lyric => "(Intro)", :durationMs => 4500 },
                    { :section => "Intro",   :chord => "F",  :lyric => "(Intro)", :durationMs => 4500 },
                    { :section => "Intro",   :chord => "Fm", :lyric => "(Intro)", :durationMs => 4500 },

                    // Verse 1
                    { :section => "Verse 1", :chord => "C",  :lyric => "When you were here before,", :durationMs => 4800 },
                    { :section => "Verse 1", :chord => "E",  :lyric => "couldn't look you in the eye.", :durationMs => 4800 },
                    { :section => "Verse 1", :chord => "F",  :lyric => "You're just like an angel,", :durationMs => 4800 },
                    { :section => "Verse 1", :chord => "Fm", :lyric => "your skin makes me cry.", :durationMs => 4800 },
                    { :section => "Verse 1", :chord => "C",  :lyric => "You float like a feather,", :durationMs => 4800 },
                    { :section => "Verse 1", :chord => "E",  :lyric => "in a beautiful world", :durationMs => 4800 },
                    { :section => "Verse 1", :chord => "F",  :lyric => "I wish I was special,", :durationMs => 4800 },
                    { :section => "Verse 1", :chord => "Fm", :lyric => "you're so fucking special.", :durationMs => 4800 },

                    // Chorus 1
                    { :section => "Chorus",  :chord => "C",  :lyric => "But I'm a creep, I'm a weirdo.", :durationMs => 4800 },
                    { :section => "Chorus",  :chord => "E",  :lyric => "I'm a weirdo.", :durationMs => 4000 },
                    { :section => "Chorus",  :chord => "F",  :lyric => "What the hell am I doing here?", :durationMs => 4800 },
                    { :section => "Chorus",  :chord => "Fm", :lyric => "I don't belong here.", :durationMs => 4800 },

                    // Verse 2
                    { :section => "Verse 2", :chord => "C",  :lyric => "I don't care if it hurts,", :durationMs => 4800 },
                    { :section => "Verse 2", :chord => "E",  :lyric => "I want to have control.", :durationMs => 4800 },
                    { :section => "Verse 2", :chord => "F",  :lyric => "I want a perfect body,", :durationMs => 4800 },
                    { :section => "Verse 2", :chord => "Fm", :lyric => "I want a perfect soul.", :durationMs => 4000 },
                    { :section => "Verse 2", :chord => "C",  :lyric => "I want you to notice,", :durationMs => 4800 },
                    { :section => "Verse 2", :chord => "E",  :lyric => "when I'm not around.", :durationMs => 4800 },
                    { :section => "Verse 2", :chord => "F",  :lyric => "You're so fucking special,", :durationMs => 4800 },
                    { :section => "Verse 2", :chord => "Fm", :lyric => "I wish I was special.", :durationMs => 4800 },

                    // Chorus 2
                    { :section => "Chorus",  :chord => "C",  :lyric => "But I'm a creep, I'm a weirdo.", :durationMs => 4800 },
                    { :section => "Chorus",  :chord => "E",  :lyric => "I'm a weirdo.", :durationMs => 4000 },
                    { :section => "Chorus",  :chord => "F",  :lyric => "What the hell am I doing here?", :durationMs => 4800 },
                    { :section => "Chorus",  :chord => "Fm", :lyric => "I don't belong here, oh-oh.", :durationMs => 4800 },

                    // Bridge
                    { :section => "Bridge",  :chord => "C",  :lyric => "She's running out the door...", :durationMs => 4800 },
                    { :section => "Bridge",  :chord => "E",  :lyric => "She's running out, she run...", :durationMs => 4800 },
                    { :section => "Bridge",  :chord => "F",  :lyric => "Ruuuuuuuuuuuuuuuuuuun...", :durationMs => 4800 },
                    { :section => "Bridge",  :chord => "Fm", :lyric => "Ruuuuuuuuuuuuuuun...", :durationMs => 4800 },

                    // Verse 3
                    { :section => "Verse 3", :chord => "C",  :lyric => "Whatever makes you happy,", :durationMs => 4800 },
                    { :section => "Verse 3", :chord => "E",  :lyric => "whatever you want.", :durationMs => 4800 },
                    { :section => "Verse 3", :chord => "F",  :lyric => "You're so fucking special,", :durationMs => 4800 },
                    { :section => "Verse 3", :chord => "Fm", :lyric => "I wish I was special,", :durationMs => 4800 },

                    // Chorus 3 / Outro
                    { :section => "Chorus",  :chord => "C",  :lyric => "But I'm a creep, I'm a weirdo.", :durationMs => 4800 },
                    { :section => "Chorus",  :chord => "E",  :lyric => "I'm a weirdo.", :durationMs => 4000 },
                    { :section => "Chorus",  :chord => "F",  :lyric => "What the hell am I doing here?", :durationMs => 4800 },
                    { :section => "Outro",   :chord => "Fm", :lyric => "I don't belong here,", :durationMs => 4800 },
                    { :section => "Outro",   :chord => "C",  :lyric => "I don't belong here.", :durationMs => 4800 }
                ]
            },

            // 5. Fake Plastic Trees - Radiohead (Easy Open Chords: D - Dsus4 - G - Em - A)
            {
                :title => "Fake Plastic Trees",
                :artist => "Radiohead",
                :capo => null,
                :defaultDurationMs => 3500,
                :steps => [
                    { :section => "Verse 1", :chord => "D",     :lyric => "Her green plastic watering can", :durationMs => 3500 },
                    { :section => "Verse 1", :chord => "Dsus4", :lyric => "For her fake Chinese rubber plant", :durationMs => 3500 },
                    { :section => "Verse 1", :chord => "G",     :lyric => "In the fake plastic earth", :durationMs => 3500 },
                    { :section => "Verse 1", :chord => "D",     :lyric => "That she bought from a rubber man", :durationMs => 3500 },
                    { :section => "Verse 1", :chord => "Dsus4", :lyric => "In a town full of rubber plans", :durationMs => 3500 },
                    { :section => "Verse 1", :chord => "G",     :lyric => "To get rid of itself", :durationMs => 3500 },
                    { :section => "Chorus",  :chord => "Em",    :lyric => "It wears her out", :durationMs => 3500 },
                    { :section => "Chorus",  :chord => "A",     :lyric => "It wears her out", :durationMs => 3500 },
                    { :section => "Chorus",  :chord => "Em",    :lyric => "It wears her out", :durationMs => 3500 },
                    { :section => "Chorus",  :chord => "A",     :lyric => "It wears...", :durationMs => 3500 },
                    { :section => "Verse 2", :chord => "D",     :lyric => "She lives with a broken man", :durationMs => 3500 },
                    { :section => "Verse 2", :chord => "Dsus4", :lyric => "A cracked polystyrene man", :durationMs => 3500 },
                    { :section => "Verse 2", :chord => "G",     :lyric => "Who just crumbles and burns", :durationMs => 3500 },
                    { :section => "Verse 2", :chord => "D",     :lyric => "He used to do surgery for girls", :durationMs => 3500 },
                    { :section => "Verse 2", :chord => "Dsus4", :lyric => "In the eighties, but gravity wins", :durationMs => 3500 },
                    { :section => "Verse 2", :chord => "G",     :lyric => "Gravity always wins", :durationMs => 3500 },
                    { :section => "Chorus",  :chord => "Em",    :lyric => "And it wears him out", :durationMs => 3500 },
                    { :section => "Chorus",  :chord => "A",     :lyric => "It wears him out", :durationMs => 3500 },
                    { :section => "Chorus",  :chord => "Em",    :lyric => "It wears him out", :durationMs => 3500 },
                    { :section => "Verse 3", :chord => "D",     :lyric => "She looks like the real thing", :durationMs => 3500 },
                    { :section => "Verse 3", :chord => "Dsus4", :lyric => "She tastes like the real thing", :durationMs => 3500 },
                    { :section => "Verse 3", :chord => "G",     :lyric => "My fake plastic love", :durationMs => 3500 },
                    { :section => "Outro",   :chord => "Em",    :lyric => "If I could be who you wanted", :durationMs => 3500 },
                    { :section => "Outro",   :chord => "A",     :lyric => "All the time, all the time...", :durationMs => 3500 },
                    { :section => "Outro",   :chord => "D",     :lyric => "All the time...", :durationMs => 3500 }
                ]
            },

            // 6. Walking Back Home - Vira Talisa (Easy Chords: C - Em - Fmaj7 - G - Dm - Am)
            {
                :title => "Walking Back Home",
                :artist => "Vira Talisa",
                :capo => null,
                :defaultDurationMs => 3000,
                :steps => [
                    { :section => "Verse 1", :chord => "C",     :lyric => "Mr. Blue, I'm feeling fine", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "Em",    :lyric => "Underneath the summer sky", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "Fmaj7", :lyric => "Strolling down the quiet street", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "G",     :lyric => "Rhythms moving with my feet", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "C",     :lyric => "Walking back home on my own", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "Em",    :lyric => "Nothing's gonna shake this tone", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "Fmaj7", :lyric => "Memories of yesterday", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "G",     :lyric => "Gently drifting far away", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Dm",    :lyric => "Through the wind and rainy days", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "I have found my own sweet ways", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "C",     :lyric => "Now the stars begin to glow", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Am",    :lyric => "In a sweet and steady flow", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "C",     :lyric => "Walking back home, feel alive", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "Em",    :lyric => "Watch the city lights arrive", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "Fmaj7", :lyric => "Living life in harmony", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "C",     :lyric => "Ooh, walking back home...", :durationMs => 3000 }
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
        triggerHaptic();
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

    // Practice speed multiplier methods
    public function getSpeedMultiplier() as Lang.Float {
        return mSpeedMultiplier;
    }

    public function cycleSpeed() as Lang.Float {
        if (mSpeedMultiplier == 1.0f) {
            mSpeedMultiplier = 1.2f;
        } else if (mSpeedMultiplier == 1.2f) {
            mSpeedMultiplier = 1.5f;
        } else if (mSpeedMultiplier == 1.5f) {
            mSpeedMultiplier = 0.8f;
        } else {
            mSpeedMultiplier = 1.0f;
        }
        Storage.setValue("SPEED_MULT", mSpeedMultiplier as Application.Storage.ValueType);
        if (mIsAutoScrolling) {
            scheduleNextStepTimer();
        }
        WatchUi.requestUpdate();
        return mSpeedMultiplier;
    }

    // Tactile haptic feedback methods
    public function isHapticEnabled() as Lang.Boolean {
        return mHapticEnabled;
    }

    public function toggleHaptic() as Lang.Boolean {
        mHapticEnabled = !mHapticEnabled;
        Storage.setValue("HAPTIC_ENABLED", mHapticEnabled as Application.Storage.ValueType);
        if (mHapticEnabled) {
            triggerHaptic();
        }
        WatchUi.requestUpdate();
        return mHapticEnabled;
    }

    public function triggerHaptic() as Void {
        if (mHapticEnabled && (Attention has :vibrate)) {
            try {
                // Short crisp pulse (40% duty cycle, 70ms duration)
                var vibeProfile = [new Attention.VibeProfile(40, 70)];
                Attention.vibrate(vibeProfile);
            } catch (e) {
                // Safe ignore if vibration hardware is busy
            }
        }
    }

    public function restartSong() as Void {
        mCurrentStepIndex = 0;
        mStatusMessage = null;
        triggerHaptic();
        if (mIsAutoScrolling) {
            scheduleNextStepTimer();
        }
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

        // Apply practice speed multiplier
        var scaledDuration = (duration.toFloat() / mSpeedMultiplier).toNumber();
        if (scaledDuration < 500) {
            scaledDuration = 500;
        }

        if (mAutoScrollTimer == null) {
            mAutoScrollTimer = new Timer.Timer();
        }
        // One-shot timer chained to the scaled duration of current step
        mAutoScrollTimer.start(method(:onAutoScrollTimer), scaledDuration, false);
    }

    public function onAutoScrollTimer() as Void {
        if (!mIsAutoScrolling) {
            return;
        }
        var currentSteps = mSongs[mCurrentSongIndex][:steps];
        if (mCurrentStepIndex < currentSteps.size() - 1) {
            mCurrentStepIndex++;
            mStatusMessage = null;
            triggerHaptic();
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
                Storage.setValue("SAVED_RAW_SONGS", data as Application.Storage.ValueType);
                mStatusMessage = "Success (" + mSongs.size().toString() + " Songs)";
            } else {
                mStatusMessage = "Failed: Invalid format";
            }
        } else {
            mStatusMessage = "Connection failed (" + responseCode.toString() + ")";
        }
        WatchUi.requestUpdate();
    }

    // Parses ChordPro text with optional durations and Capo metadata
    private function parseChordProText(rawText as Lang.String) as Lang.Array<SongData> {
        var result = [] as Lang.Array<SongData>;
        var currentSongTitle = "";
        var currentSongCapo = null as Lang.String?;
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

            // Song header line starting with #
            if (line.length() > 1 && line.substring(0, 1).equals("#")) {
                if (currentSongTitle.length() > 0 && currentSteps.size() > 0) {
                    result.add({
                        :title => currentSongTitle,
                        :artist => "Web",
                        :capo => currentSongCapo,
                        :steps => currentSteps,
                        :defaultDurationMs => 3500
                    });
                    currentSteps = [] as Lang.Array<SongStep>;
                    currentSongCapo = null;
                }
                var rawTitle = line.substring(1, line.length());
                while (rawTitle.length() > 0 && rawTitle.substring(0, 1).equals(" ")) {
                    rawTitle = rawTitle.substring(1, rawTitle.length());
                }

                // Check for embedded Capo in title e.g. "Hey Jude (Capo 3)"
                var capoIdx = rawTitle.find("Capo ");
                if (capoIdx != null && rawTitle.find("No Capo") == null) {
                    var cNum = capoIdx as Lang.Number;
                    var endCapo = rawTitle.length();
                    var closeP = rawTitle.find(")");
                    if (closeP != null && (closeP as Lang.Number) > cNum) {
                        endCapo = closeP as Lang.Number;
                    }
                    var commaP = rawTitle.find(",");
                    if (commaP != null && (commaP as Lang.Number) > cNum && (commaP as Lang.Number) < endCapo) {
                        endCapo = commaP as Lang.Number;
                    }
                    currentSongCapo = rawTitle.substring(cNum, endCapo);
                }

                var dashIdx = rawTitle.find(" - ");
                if (dashIdx != null) {
                    currentSongTitle = rawTitle.substring(0, dashIdx as Lang.Number);
                } else {
                    currentSongTitle = rawTitle;
                }

            } else if (line.find("{capo:") != null) {
                var cStart = line.find("{capo:") as Lang.Number;
                var cEnd = line.find("}");
                if (cEnd != null && (cEnd as Lang.Number) > cStart + 6) {
                    var capoVal = line.substring(cStart + 6, cEnd as Lang.Number);
                    while (capoVal.length() > 0 && capoVal.substring(0, 1).equals(" ")) {
                        capoVal = capoVal.substring(1, capoVal.length());
                    }
                    if (!capoVal.equals("No Capo") && !capoVal.equals("none") && capoVal.length() > 0) {
                        currentSongCapo = capoVal;
                    }
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
                :capo => currentSongCapo,
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

    public function getSongCapo(index as Lang.Number) as Lang.String? {
        if (index >= 0 && index < mSongs.size()) {
            var song = mSongs[index];
            if (song.hasKey(:capo)) {
                return song[:capo] as Lang.String?;
            }
        }
        return null;
    }

    public function getCurrentCapo() as Lang.String? {
        return getSongCapo(mCurrentSongIndex);
    }

    public function selectSong(index as Lang.Number) as Void {
        if (index >= 0 && index < mSongs.size()) {
            mCurrentSongIndex = index;
            mCurrentStepIndex = 0;
            mStatusMessage = null;
            triggerHaptic();
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

    public function getNextLyric() as Lang.String? {
        var currentSteps = mSongs[mCurrentSongIndex][:steps];
        if (mCurrentStepIndex + 1 < currentSteps.size()) {
            return currentSteps[mCurrentStepIndex + 1][:lyric] as Lang.String?;
        }
        return null;
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
            triggerHaptic();
            if (mIsAutoScrolling) {
                scheduleNextStepTimer();
            }
            WatchUi.requestUpdate();
        }
    }

    public function prevStep() as Void {
        if (mCurrentStepIndex > 0) {
            mCurrentStepIndex--;
            mStatusMessage = null;
            triggerHaptic();
            if (mIsAutoScrolling) {
                scheduleNextStepTimer();
            }
            WatchUi.requestUpdate();
        }
    }
}