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

    // Raw GitHub URL for one-click Web Sync directly from your repo!
    private var mSyncUrl as Lang.String = "https://raw.githubusercontent.com/NaufalFahrozi/GuitarPrompter/main/songs.txt";

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
            // 1. Take Me Home, Country Roads - John Denver
            {
                :title => "Country Roads",
                :artist => "John Denver",
                :defaultDurationMs => 3000,
                :steps => [
                    { :section => "Verse 1", :chord => "G",     :lyric => "Almost heaven, West Virginia", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "Em",    :lyric => "Blue Ridge Mountains, Shenandoah River", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "G",     :lyric => "Life is old there, older than the trees", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "D",     :lyric => "Younger than the mountains,", :durationMs => 2500 },
                    { :section => "Verse 1", :chord => "C",     :lyric => "Growin' like a breeze", :durationMs => 2500 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "Country roads, take me home", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "D",     :lyric => "To the place I belong", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Em",    :lyric => "West Virginia, mountain mama", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "C",     :lyric => "Take me home, country roads", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "G",     :lyric => "All my memories gather 'round her", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "Em",    :lyric => "Miner's lady, stranger to blue water", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "G",     :lyric => "Dark and dusty, painted on the sky", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "D",     :lyric => "Misty taste of moonshine,", :durationMs => 2500 },
                    { :section => "Verse 2", :chord => "C",     :lyric => "Teardrop in my eye", :durationMs => 2500 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "Country roads, take me home", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "D",     :lyric => "To the place I belong", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Em",    :lyric => "West Virginia, mountain mama", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "C",     :lyric => "Take me home, country roads", :durationMs => 3000 },
                    { :section => "Bridge",  :chord => "Em",    :lyric => "I hear her voice in the mornin' hour", :durationMs => 2500 },
                    { :section => "Bridge",  :chord => "D",     :lyric => "Radio reminds me of my home far away", :durationMs => 2500 },
                    { :section => "Bridge",  :chord => "G",     :lyric => "Drivin' down the road I get a feelin'", :durationMs => 2500 },
                    { :section => "Bridge",  :chord => "D7",    :lyric => "That I should have been home yesterday", :durationMs => 2500 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "Country roads, take me home", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "D",     :lyric => "To the place I belong", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Em",    :lyric => "West Virginia, mountain mama", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "C",     :lyric => "Take me home, country roads", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "G",     :lyric => "Take me home, country roads", :durationMs => 3000 }
                ]
            },

            // 2. Hey Jude - The Beatles (Capo 3, Easy Chords)
            {
                :title => "Hey Jude",
                :artist => "The Beatles",
                :defaultDurationMs => 3500,
                :steps => [
                    { :section => "Verse 1", :chord => "C",     :lyric => "Hey Jude, don't make it bad", :durationMs => 3500 },
                    { :section => "Verse 1", :chord => "G",     :lyric => "Take a sad song and make it better", :durationMs => 3500 },
                    { :section => "Verse 1", :chord => "G7",    :lyric => "Remember to let her into your heart", :durationMs => 3500 },
                    { :section => "Verse 1", :chord => "C",     :lyric => "Then you can start to make it better", :durationMs => 3500 },
                    { :section => "Verse 2", :chord => "C",     :lyric => "Hey Jude, don't be afraid", :durationMs => 3500 },
                    { :section => "Verse 2", :chord => "G",     :lyric => "You were made to go out and get her", :durationMs => 3500 },
                    { :section => "Verse 2", :chord => "G7",    :lyric => "The minute you let her under your skin", :durationMs => 3500 },
                    { :section => "Verse 2", :chord => "C",     :lyric => "Then you begin to make it better", :durationMs => 3500 },
                    { :section => "Chorus",  :chord => "C7",    :lyric => "And anytime you feel the pain, refrain", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Fmaj7", :lyric => "Don't carry the world upon your shoulders", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "C",     :lyric => "For well you know that it's a fool", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "Who plays it cool by making it colder", :durationMs => 3000 },
                    { :section => "Verse 3", :chord => "C",     :lyric => "Hey Jude, don't let me down", :durationMs => 3500 },
                    { :section => "Verse 3", :chord => "G",     :lyric => "You have found her, now go and get her", :durationMs => 3500 },
                    { :section => "Verse 3", :chord => "G7",    :lyric => "Remember to let her into your heart", :durationMs => 3500 },
                    { :section => "Verse 3", :chord => "C",     :lyric => "Then you can start to make it better", :durationMs => 3500 },
                    { :section => "Chorus",  :chord => "C7",    :lyric => "So let it out and let it in, begin", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Fmaj7", :lyric => "You're waiting for someone to perform with", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "C",     :lyric => "The movement you need is on your shoulder", :durationMs => 3000 },
                    { :section => "Verse 4", :chord => "C",     :lyric => "Hey Jude, don't make it bad", :durationMs => 3500 },
                    { :section => "Verse 4", :chord => "G",     :lyric => "Take a sad song and make it better", :durationMs => 3500 },
                    { :section => "Verse 4", :chord => "G7",    :lyric => "Remember to let her under your skin", :durationMs => 3500 },
                    { :section => "Verse 4", :chord => "C",     :lyric => "Then you'll begin to make it better", :durationMs => 3500 },
                    { :section => "Outro",   :chord => "C",     :lyric => "Na, na na na na na na", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "Bb",    :lyric => "Na na na na,", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "Fmaj7", :lyric => "Hey Jude!", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "C",     :lyric => "Jude, Jude, Jude, yeah!", :durationMs => 3000 }
                ]
            },

            // 3. Here Comes The Sun - The Beatles (Capo 7, Easy Chords)
            {
                :title => "Here Comes The Sun",
                :artist => "The Beatles",
                :defaultDurationMs => 3000,
                :steps => [
                    { :section => "Chorus",  :chord => "D",     :lyric => "Here comes the sun, doo-doo-doo-doo", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "Here comes the sun,", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "E7",    :lyric => "And I say, it's alright", :durationMs => 2500 },
                    { :section => "Verse 1", :chord => "D",     :lyric => "Little darling, long cold lonely winter", :durationMs => 3500 },
                    { :section => "Verse 1", :chord => "G",     :lyric => "Little darling, feels like years since here", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "A7",    :lyric => "It's been here", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "D",     :lyric => "Here comes the sun, doo-doo-doo-doo", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "Here comes the sun, it's alright", :durationMs => 3000 },
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
                    { :section => "Chorus",  :chord => "G",     :lyric => "Here comes the sun, and I say", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "D",     :lyric => "It's alright, it's alright", :durationMs => 3000 }
                ]
            },

            // 4. Creep - Radiohead (Easy Open Chords: G - B7 - C - Cm)
            {
                :title => "Creep",
                :artist => "Radiohead",
                :defaultDurationMs => 5200,
                :steps => [
                    { :section => "Verse 1", :chord => "G",     :lyric => "When you were here before", :durationMs => 5200 },
                    { :section => "Verse 1", :chord => "B7",    :lyric => "Couldn't look you in the eye", :durationMs => 5200 },
                    { :section => "Verse 1", :chord => "C",     :lyric => "You're just like an angel", :durationMs => 5200 },
                    { :section => "Verse 1", :chord => "Cm",    :lyric => "Your skin makes me cry", :durationMs => 5200 },
                    { :section => "Verse 2", :chord => "G",     :lyric => "You float like a feather", :durationMs => 5200 },
                    { :section => "Verse 2", :chord => "B7",    :lyric => "In a beautiful world", :durationMs => 5200 },
                    { :section => "Verse 2", :chord => "C",     :lyric => "I wish I was special", :durationMs => 5200 },
                    { :section => "Verse 2", :chord => "Cm",    :lyric => "You're so very special", :durationMs => 5200 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "But I'm a creep, I'm a weirdo", :durationMs => 5200 },
                    { :section => "Chorus",  :chord => "B7",    :lyric => "What the hell am I doin' here?", :durationMs => 5200 },
                    { :section => "Chorus",  :chord => "C",     :lyric => "I don't belong here", :durationMs => 5200 },
                    { :section => "Chorus",  :chord => "Cm",    :lyric => "I don't care if it hurts", :durationMs => 5200 },
                    { :section => "Verse 3", :chord => "G",     :lyric => "I want a perfect body, perfect soul", :durationMs => 5200 },
                    { :section => "Verse 3", :chord => "B7",    :lyric => "I want you to notice when not around", :durationMs => 5200 },
                    { :section => "Verse 3", :chord => "C",     :lyric => "You're so very special", :durationMs => 5200 },
                    { :section => "Verse 3", :chord => "Cm",    :lyric => "I wish I was special", :durationMs => 5200 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "She's running out the door, she run", :durationMs => 5200 },
                    { :section => "Chorus",  :chord => "B7",    :lyric => "Run, run, run, run... Run...", :durationMs => 5200 },
                    { :section => "Outro",   :chord => "G",     :lyric => "Whatever makes you happy, what you want", :durationMs => 5200 },
                    { :section => "Outro",   :chord => "B7",    :lyric => "You're so very special...", :durationMs => 5200 },
                    { :section => "Outro",   :chord => "C",     :lyric => "I wish I was special...", :durationMs => 5200 },
                    { :section => "Outro",   :chord => "Cm",    :lyric => "I don't belong here...", :durationMs => 5200 }
                ]
            },

            // 5. Fake Plastic Trees - Radiohead (Easy Open Chords: D - Dsus4 - G - Em - A)
            {
                :title => "Fake Plastic Trees",
                :artist => "Radiohead",
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
                    { :section => "Outro",   :chord => "A",     :lyric => "All the time, all the time...", :durationMs => 3500 }
                ]
            },

            // 6. Mary On A Cross - Ghost (Capo 3, Easy Chords: Am - Fmaj7 - C - G)
            {
                :title => "Mary On A Cross",
                :artist => "Ghost",
                :defaultDurationMs => 3000,
                :steps => [
                    { :section => "Verse 1", :chord => "Am",    :lyric => "We were young and we were wild", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "Fmaj7", :lyric => "In the night, our hearts collide", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "C",     :lyric => "In the temple of our love", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "G",     :lyric => "Shining like the stars above", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Am",    :lyric => "You go down just like Holy Mary", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Fmaj7", :lyric => "Mary on a, Mary on a cross", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "C",     :lyric => "Not just another bloody Mary", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "Mary on a, Mary on a cross", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "Am",    :lyric => "If you choose to run away with me", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "Fmaj7", :lyric => "I will tickle you internally", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "C",     :lyric => "And I see nothing wrong with that", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "G",     :lyric => "Mary on a, Mary on a cross", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Am",    :lyric => "You go down just like Holy Mary", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Fmaj7", :lyric => "Mary on a, Mary on a cross", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "C",     :lyric => "Not just another bloody Mary", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "Mary on a, Mary on a cross", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "Fmaj7", :lyric => "Nothing's gonna stop us now", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "G",     :lyric => "Mary on a cross", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "Am",    :lyric => "Mary on a cross...", :durationMs => 3000 }
                ]
            },

            // 7. Walking Back Home - Vira Talisa (Easy Chords: C - Em - Fmaj7 - G - Dm - Am)
            {
                :title => "Walking Back Home",
                :artist => "Vira Talisa",
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
            },

            // 8. If You Know That I'm Lonely - FUR (Capo 1, Easy Chords: C - E7 - Am - Fmaj7 - G)
            {
                :title => "If You Know Lonely",
                :artist => "FUR",
                :defaultDurationMs => 3000,
                :steps => [
                    { :section => "Verse 1", :chord => "C",     :lyric => "If you know that I'm lonely", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "E7",    :lyric => "Why'd you have to leave me?", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "Am",    :lyric => "Waiting by the telephone", :durationMs => 3000 },
                    { :section => "Verse 1", :chord => "Fmaj7", :lyric => "Sitting on my own at home", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "C",     :lyric => "I was looking for someone", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "E7",    :lyric => "To hold through the night", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "Am",    :lyric => "But you walked away so fast", :durationMs => 3000 },
                    { :section => "Verse 2", :chord => "Fmaj7", :lyric => "Vanished in the morning light", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Dm",    :lyric => "Tell me what I did so wrong", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "G",     :lyric => "To make you stay away this long", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "C",     :lyric => "Baby won't you come around", :durationMs => 3000 },
                    { :section => "Chorus",  :chord => "Am",    :lyric => "Lift me up from underground", :durationMs => 3000 },
                    { :section => "Verse 3", :chord => "C",     :lyric => "If you know that I'm lonely", :durationMs => 3000 },
                    { :section => "Verse 3", :chord => "E7",    :lyric => "Why don't you call my name?", :durationMs => 3000 },
                    { :section => "Verse 3", :chord => "Am",    :lyric => "Playing this romantic game", :durationMs => 3000 },
                    { :section => "Verse 3", :chord => "Fmaj7", :lyric => "Only brings me tears and pain", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "C",     :lyric => "Won't you come back home to me", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "E7",    :lyric => "Set this lonely spirit free", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "Am",    :lyric => "If you know that I'm lonely...", :durationMs => 3000 },
                    { :section => "Outro",   :chord => "Fmaj7", :lyric => "Don't leave me alone tonight", :durationMs => 3000 }
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