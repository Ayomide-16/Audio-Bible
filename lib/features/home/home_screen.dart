import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/bible_repository.dart';
import '../../data/models/bible_models.dart';
import '../../core/theme/app_theme.dart';
import '../reader/reader_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import '../navigation/honeycomb_navigation.dart';
import '../navigation/list_navigation.dart';
import '../navigation/grid_navigation.dart';

/// Provider for recent chapters
final recentChaptersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final recent = prefs.getStringList('recent_chapters') ?? [];
  return recent.take(5).map((e) {
    final parts = e.split(':');
    if (parts.length >= 3) {
      return {
        'bookId': int.tryParse(parts[0]) ?? 1,
        'chapter': int.tryParse(parts[1]) ?? 1,
        'bookName': parts[2],
      };
    }
    return {'bookId': 1, 'chapter': 1, 'bookName': 'Genesis'};
  }).toList();
});

/// Provider for last read position
final lastReadProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final bookId = prefs.getInt('last_book');
  final chapter = prefs.getInt('last_chapter');
  final bookName = prefs.getString('last_book_name');
  if (bookId != null && chapter != null && bookName != null) {
    return {'bookId': bookId, 'chapter': chapter, 'bookName': bookName};
  }
  return null;
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final bibleAsync = ref.watch(bibleProvider);
    final lastReadAsync = ref.watch(lastReadProvider);
    final navStyle = ref.watch(navigationStyleProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo and search (fixed at top)
            _buildHeader(context),
            
            // Continue reading section (if available)
            lastReadAsync.when(
              data: (lastRead) => lastRead != null 
                  ? _buildContinueReading(context, lastRead)
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            // Navigation based on style (takes remaining space)
            Expanded(
              child: bibleAsync.when(
                data: (bible) => _buildNavigation(context, bible, navStyle),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Error loading Bible: $e'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/icon.png',
                  width: 48,
                  height: 48,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.book, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audio Bible',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'King James Version',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 16),
          
          // Search bar
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Search "John 3:16" or "love"...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
        ],
      ),
    );
  }

  Widget _buildContinueReading(BuildContext context, Map<String, dynamic> lastRead) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: GestureDetector(
        onTap: () => _openChapter(
          context, 
          lastRead['bookId'], 
          lastRead['chapter'],
          lastRead['bookName'],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continue Reading',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${lastRead['bookName']} ${lastRead['chapter']}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
    );
  }

  Widget _buildNavigation(BuildContext context, Bible bible, NavigationStyle style) {
    switch (style) {
      case NavigationStyle.honeycomb:
        return HoneycombNavigation(
          bible: bible,
          onChapterSelected: (bookId, chapter, bookName) {
            _openChapter(context, bookId, chapter, bookName);
          },
        );
      case NavigationStyle.list:
        return ListNavigation(
          bible: bible,
          onChapterSelected: (bookId, chapter, bookName) {
            _openChapter(context, bookId, chapter, bookName);
          },
        );
      case NavigationStyle.grid:
        return GridNavigation(
          bible: bible,
          onChapterSelected: (bookId, chapter, bookName) {
            _openChapter(context, bookId, chapter, bookName);
          },
        );
    }
  }

  void _openChapter(BuildContext context, int bookId, int chapter, String bookName) async {
    // Save to recent
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList('recent_chapters') ?? [];
    final entry = '$bookId:$chapter:$bookName';
    recent.removeWhere((e) => e == entry);
    recent.insert(0, entry);
    await prefs.setStringList('recent_chapters', recent.take(10).toList());
    
    // Save last read
    await prefs.setInt('last_book', bookId);
    await prefs.setInt('last_chapter', chapter);
    await prefs.setString('last_book_name', bookName);
    
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReaderScreen(
            bookId: bookId,
            chapterNumber: chapter,
          ),
        ),
      );
    }
  }
}
