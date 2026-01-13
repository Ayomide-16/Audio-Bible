import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/bible_repository.dart';
import '../../data/models/bible_models.dart';
import '../../core/theme/app_theme.dart';
import '../reader/reader_screen.dart';
import '../search/search_screen.dart';
import '../navigation/quick_nav_dialog.dart';

/// Provider for recent chapters
final recentChaptersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final recent = prefs.getStringList('recent_chapters') ?? [];
  return recent.take(5).map((e) {
    final parts = e.split(':');
    return {
      'bookId': int.parse(parts[0]),
      'chapter': int.parse(parts[1]),
      'bookName': parts[2],
    };
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
    final recentAsync = ref.watch(recentChaptersProvider);
    
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar with search
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),
            
            // Quick access - Continue reading
            SliverToBoxAdapter(
              child: lastReadAsync.when(
                data: (lastRead) => lastRead != null 
                    ? _buildContinueReading(context, lastRead)
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            
            // Daily verse
            SliverToBoxAdapter(
              child: _buildDailyVerse(context),
            ),
            
            // Old Testament section
            SliverToBoxAdapter(
              child: bibleAsync.when(
                data: (bible) => _buildBookSection(
                  context, 
                  'Old Testament', 
                  bible.oldTestament,
                ),
                loading: () => _buildLoadingSection(),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
            
            // New Testament section
            SliverToBoxAdapter(
              child: bibleAsync.when(
                data: (bible) => _buildBookSection(
                  context, 
                  'New Testament', 
                  bible.newTestament,
                ),
                loading: () => _buildLoadingSection(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            
            // Recent history
            SliverToBoxAdapter(
              child: recentAsync.when(
                data: (recent) => recent.isNotEmpty 
                    ? _buildRecentHistory(context, recent)
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      
      // Quick navigation FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickNav(context),
        icon: const Icon(Icons.bolt_rounded),
        label: const Text('Quick Jump'),
      ).animate().scale(delay: 500.ms, duration: 300.ms),
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
              // Logo/Title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Audio Bible',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 44),
                    child: Text(
                      'King James Version',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  // TODO: Settings
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          
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
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                ),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
              ],
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

  Widget _buildDailyVerse(BuildContext context) {
    // Sample daily verse - in production, this would be fetched
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.accent.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  'Verse of the Day',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '"For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life."',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _openChapter(context, 43, 3, 'John'),
              child: Text(
                '— John 3:16',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms),
    );
  }

  Widget _buildBookSection(BuildContext context, String title, List<Book> books) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildBookChip(context, book),
                ).animate(delay: (50 * index).ms).fadeIn().slideX(begin: 0.2);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookChip(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () => _showChapterSelector(context, book),
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getBookAbbreviation(book.name),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${book.chapterCount} ch',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHistory(BuildContext context, List<Map<String, dynamic>> recent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recent.map((item) {
              return ActionChip(
                label: Text('${item['bookName']} ${item['chapter']}'),
                onPressed: () => _openChapter(
                  context,
                  item['bookId'],
                  item['chapter'],
                  item['bookName'],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSection() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  String _getBookAbbreviation(String name) {
    final abbreviations = {
      'Genesis': 'Gen',
      'Exodus': 'Exod',
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
      'Jonah': 'Jon',
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
      '1 Thessalonians': '1 Thes',
      '2 Thessalonians': '2 Thes',
      '1 Timothy': '1 Tim',
      '2 Timothy': '2 Tim',
      'Titus': 'Titus',
      'Philemon': 'Phlm',
      'Hebrews': 'Heb',
      'James': 'Jas',
      '1 Peter': '1 Pet',
      '2 Peter': '2 Pet',
      '1 John': '1 Jn',
      '2 John': '2 Jn',
      '3 John': '3 Jn',
      'Jude': 'Jude',
      'Revelation': 'Rev',
    };
    return abbreviations[name] ?? name.substring(0, 3);
  }

  void _showChapterSelector(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ChapterSelectorSheet(book: book),
    );
  }

  void _showQuickNav(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const QuickNavDialog(),
    );
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

/// Chapter selector bottom sheet
class _ChapterSelectorSheet extends StatelessWidget {
  final Book book;

  const _ChapterSelectorSheet({required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  book.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                Text(
                  '${book.chapterCount} chapters',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Chapter grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: book.chapterCount,
              itemBuilder: (context, index) {
                final chapter = book.chapters[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReaderScreen(
                          bookId: book.id,
                          chapterNumber: chapter.chapter,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${chapter.chapter}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
