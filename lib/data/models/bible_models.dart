import 'package:equatable/equatable.dart';

/// Represents a book of the Bible
class Book extends Equatable {
  final int id;
  final String name;
  final String testament; // 'OT' or 'NT'
  final List<Chapter> chapters;

  const Book({
    required this.id,
    required this.name,
    required this.testament,
    required this.chapters,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as int,
      name: json['name'] as String,
      testament: json['testament'] as String,
      chapters: (json['chapters'] as List)
          .map((c) => Chapter.fromJson(c, json['id'] as int, json['name'] as String))
          .toList(),
    );
  }

  int get chapterCount => chapters.length;
  
  bool get isOldTestament => testament == 'OT';
  bool get isNewTestament => testament == 'NT';

  /// Get audio folder path for this book
  String get audioFolderPath => '$id';

  @override
  List<Object?> get props => [id, name, testament];
}

/// Represents a chapter in a book
class Chapter extends Equatable {
  final int bookId;
  final String bookName;
  final int chapter;
  final String title;
  final List<Verse> verses;

  const Chapter({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.title,
    required this.verses,
  });

  factory Chapter.fromJson(Map<String, dynamic> json, int bookId, String bookName) {
    return Chapter(
      bookId: bookId,
      bookName: bookName,
      chapter: json['chapter'] as int,
      title: json['title'] as String,
      verses: (json['verses'] as List)
          .map((v) => Verse.fromJson(v, bookId, bookName, json['chapter'] as int))
          .toList(),
    );
  }

  int get verseCount => verses.length;
  
  /// Get the audio file path for this chapter
  String get audioFileName => '$chapter.mp3';
  String get audioPath => '$bookId/$audioFileName';

  /// Get a specific verse by number
  Verse? getVerse(int verseNumber) {
    try {
      return verses.firstWhere((v) => v.verse == verseNumber);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [bookId, chapter, title];
}

/// Represents a single verse
class Verse extends Equatable {
  final int bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;

  const Verse({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  factory Verse.fromJson(Map<String, dynamic> json, int bookId, String bookName, int chapter) {
    return Verse(
      bookId: bookId,
      bookName: bookName,
      chapter: chapter,
      verse: json['verse'] as int,
      text: json['text'] as String,
    );
  }

  /// Create from search index entry
  factory Verse.fromSearchIndex(Map<String, dynamic> json) {
    return Verse(
      bookId: json['bookId'] as int,
      bookName: json['bookName'] as String,
      chapter: json['chapter'] as int,
      verse: json['verse'] as int,
      text: json['text'] as String,
    );
  }

  /// Full reference string (e.g., "Genesis 1:1")
  String get reference => '$bookName $chapter:$verse';

  /// Short reference (e.g., "Gen 1:1")
  String get shortReference {
    final abbr = _bookAbbreviations[bookName] ?? bookName.substring(0, 3);
    return '$abbr $chapter:$verse';
  }

  @override
  List<Object?> get props => [bookId, chapter, verse];

  static const Map<String, String> _bookAbbreviations = {
    'Genesis': 'Gen',
    'Exodus': 'Exo',
    'Leviticus': 'Lev',
    'Numbers': 'Num',
    'Deuteronomy': 'Deut',
    'Joshua': 'Josh',
    'Judges': 'Judg',
    'Ruth': 'Ruth',
    '1 Samuel': '1 Sam',
    '2 Samuel': '2 Sam',
    '1 Kings': '1 Kgs',
    '2 Kings': '2 Kgs',
    '1 Chronicles': '1 Chr',
    '2 Chronicles': '2 Chr',
    'Ezra': 'Ezra',
    'Nehemiah': 'Neh',
    'Esther': 'Esth',
    'Job': 'Job',
    'Psalms': 'Ps',
    'Proverbs': 'Prov',
    'Ecclesiastes': 'Eccl',
    'Song of Solomon': 'Song',
    'Isaiah': 'Isa',
    'Jeremiah': 'Jer',
    'Lamentations': 'Lam',
    'Ezekiel': 'Ezek',
    'Daniel': 'Dan',
    'Hosea': 'Hos',
    'Joel': 'Joel',
    'Amos': 'Amos',
    'Obadiah': 'Obad',
    'Jonah': 'Jonah',
    'Micah': 'Mic',
    'Nahum': 'Nah',
    'Habakkuk': 'Hab',
    'Zephaniah': 'Zeph',
    'Haggai': 'Hag',
    'Zechariah': 'Zech',
    'Malachi': 'Mal',
    'Matthew': 'Matt',
    'Mark': 'Mark',
    'Luke': 'Luke',
    'John': 'John',
    'Acts': 'Acts',
    'Romans': 'Rom',
    '1 Corinthians': '1 Cor',
    '2 Corinthians': '2 Cor',
    'Galatians': 'Gal',
    'Ephesians': 'Eph',
    'Philippians': 'Phil',
    'Colossians': 'Col',
    '1 Thessalonians': '1 Thess',
    '2 Thessalonians': '2 Thess',
    '1 Timothy': '1 Tim',
    '2 Timothy': '2 Tim',
    'Titus': 'Titus',
    'Philemon': 'Phlm',
    'Hebrews': 'Heb',
    'James': 'Jas',
    '1 Peter': '1 Pet',
    '2 Peter': '2 Pet',
    '1 John': '1 John',
    '2 John': '2 John',
    '3 John': '3 John',
    'Jude': 'Jude',
    'Revelation': 'Rev',
  };
}

/// Bible data wrapper
class Bible extends Equatable {
  final String version;
  final String name;
  final List<Book> books;

  const Bible({
    required this.version,
    required this.name,
    required this.books,
  });

  factory Bible.fromJson(Map<String, dynamic> json) {
    return Bible(
      version: json['version'] as String,
      name: json['name'] as String,
      books: (json['books'] as List)
          .map((b) => Book.fromJson(b))
          .toList(),
    );
  }

  /// Get Old Testament books
  List<Book> get oldTestament => books.where((b) => b.isOldTestament).toList();
  
  /// Get New Testament books
  List<Book> get newTestament => books.where((b) => b.isNewTestament).toList();

  /// Get book by ID
  Book? getBook(int id) {
    try {
      return books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get book by name
  Book? getBookByName(String name) {
    try {
      return books.firstWhere(
        (b) => b.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [version, name];
}
