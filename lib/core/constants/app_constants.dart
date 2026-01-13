/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Audio Bible';
  static const String appVersion = '1.0.0';
  static const String bibleVersion = 'KJV';
  
  // Audio Settings
  static const List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  static const double defaultPlaybackSpeed = 1.0;
  
  // Reading Settings
  static const double minFontSize = 14.0;
  static const double maxFontSize = 32.0;
  static const double defaultFontSize = 18.0;
  static const double fontSizeStep = 2.0;
  
  // Sleep Timer Options (in minutes)
  static const List<int> sleepTimerOptions = [5, 10, 15, 30, 45, 60];
  
  // Bible Structure
  static const int totalBooks = 66;
  static const int oldTestamentBooks = 39;
  static const int newTestamentBooks = 27;
  
  // Search
  static const int maxSearchResults = 100;
  static const int searchDebounceMs = 300;
  
  // Cache Keys
  static const String lastBookKey = 'last_book';
  static const String lastChapterKey = 'last_chapter';
  static const String lastVerseKey = 'last_verse';
  static const String fontSizeKey = 'font_size';
  static const String themeKey = 'theme';
  static const String playbackSpeedKey = 'playback_speed';
}

/// Book name to ID mapping
class BookIds {
  static const Map<String, int> nameToId = {
    'Genesis': 1,
    'Exodus': 2,
    'Leviticus': 3,
    'Numbers': 4,
    'Deuteronomy': 5,
    'Joshua': 6,
    'Judges': 7,
    'Ruth': 8,
    '1 Samuel': 9,
    '2 Samuel': 10,
    '1 Kings': 11,
    '2 Kings': 12,
    '1 Chronicles': 13,
    '2 Chronicles': 14,
    'Ezra': 15,
    'Nehemiah': 16,
    'Esther': 17,
    'Job': 18,
    'Psalms': 19,
    'Proverbs': 20,
    'Ecclesiastes': 21,
    'Song of Solomon': 22,
    'Isaiah': 23,
    'Jeremiah': 24,
    'Lamentations': 25,
    'Ezekiel': 26,
    'Daniel': 27,
    'Hosea': 28,
    'Joel': 29,
    'Amos': 30,
    'Obadiah': 31,
    'Jonah': 32,
    'Micah': 33,
    'Nahum': 34,
    'Habakkuk': 35,
    'Zephaniah': 36,
    'Haggai': 37,
    'Zechariah': 38,
    'Malachi': 39,
    'Matthew': 40,
    'Mark': 41,
    'Luke': 42,
    'John': 43,
    'Acts': 44,
    'Romans': 45,
    '1 Corinthians': 46,
    '2 Corinthians': 47,
    'Galatians': 48,
    'Ephesians': 49,
    'Philippians': 50,
    'Colossians': 51,
    '1 Thessalonians': 52,
    '2 Thessalonians': 53,
    '1 Timothy': 54,
    '2 Timothy': 55,
    'Titus': 56,
    'Philemon': 57,
    'Hebrews': 58,
    'James': 59,
    '1 Peter': 60,
    '2 Peter': 61,
    '1 John': 62,
    '2 John': 63,
    '3 John': 64,
    'Jude': 65,
    'Revelation': 66,
  };
}
