import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bible_models.dart';

/// Provider for Bible data
final bibleProvider = FutureProvider<Bible>((ref) async {
  return BibleRepository().loadBible();
});

/// Provider for search index (flattened verse list)
final searchIndexProvider = FutureProvider<List<Verse>>((ref) async {
  return BibleRepository().loadSearchIndex();
});

/// Repository for loading and accessing Bible data
class BibleRepository {
  static Bible? _cachedBible;
  static List<Verse>? _cachedSearchIndex;

  /// Load Bible data from assets
  Future<Bible> loadBible() async {
    if (_cachedBible != null) {
      return _cachedBible!;
    }

    final jsonString = await rootBundle.loadString('assets/data/bible.json');
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    _cachedBible = Bible.fromJson(jsonData);
    return _cachedBible!;
  }

  /// Load search index for fast verse lookup
  Future<List<Verse>> loadSearchIndex() async {
    if (_cachedSearchIndex != null) {
      return _cachedSearchIndex!;
    }

    final jsonString = await rootBundle.loadString('assets/data/search_index.json');
    final jsonData = json.decode(jsonString) as List<dynamic>;
    _cachedSearchIndex = jsonData
        .map((v) => Verse.fromSearchIndex(v as Map<String, dynamic>))
        .toList();
    return _cachedSearchIndex!;
  }

  /// Get a specific book by ID
  Future<Book?> getBook(int bookId) async {
    final bible = await loadBible();
    return bible.getBook(bookId);
  }

  /// Get a specific chapter
  Future<Chapter?> getChapter(int bookId, int chapterNumber) async {
    final book = await getBook(bookId);
    if (book == null) return null;
    
    try {
      return book.chapters.firstWhere((c) => c.chapter == chapterNumber);
    } catch (_) {
      return null;
    }
  }

  /// Get a specific verse
  Future<Verse?> getVerse(int bookId, int chapter, int verse) async {
    final chapterData = await getChapter(bookId, chapter);
    return chapterData?.getVerse(verse);
  }

  /// Simple keyword search
  Future<List<Verse>> searchKeyword(String query) async {
    if (query.trim().isEmpty) return [];
    
    final searchIndex = await loadSearchIndex();
    final lowerQuery = query.toLowerCase();
    
    return searchIndex.where((verse) {
      return verse.text.toLowerCase().contains(lowerQuery);
    }).take(100).toList(); // Limit to 100 results
  }

  /// Search within a specific testament
  Future<List<Verse>> searchInTestament(String query, {required bool oldTestament}) async {
    if (query.trim().isEmpty) return [];
    
    final bible = await loadBible();
    final searchIndex = await loadSearchIndex();
    final lowerQuery = query.toLowerCase();
    
    // Get book IDs for the testament
    final testamentBooks = oldTestament 
        ? bible.oldTestament.map((b) => b.id).toSet()
        : bible.newTestament.map((b) => b.id).toSet();
    
    return searchIndex.where((verse) {
      return testamentBooks.contains(verse.bookId) &&
             verse.text.toLowerCase().contains(lowerQuery);
    }).take(100).toList();
  }

  /// Get total verse count
  Future<int> getTotalVerseCount() async {
    final searchIndex = await loadSearchIndex();
    return searchIndex.length;
  }
}
