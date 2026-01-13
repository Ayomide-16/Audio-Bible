import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/bible_repository.dart';
import '../../data/models/bible_models.dart';
import '../../core/theme/app_theme.dart';
import '../reader/reader_screen.dart';

class QuickNavDialog extends ConsumerStatefulWidget {
  const QuickNavDialog({super.key});

  @override
  ConsumerState<QuickNavDialog> createState() => _QuickNavDialogState();
}

class _QuickNavDialogState extends ConsumerState<QuickNavDialog> {
  final TextEditingController _searchController = TextEditingController();
  Book? _selectedBook;
  List<Book> _filteredBooks = [];
  
  // Popular books for quick access
  final List<String> _popularBooks = [
    'Genesis', 'Psalms', 'Proverbs', 'Matthew', 'John', 'Romans', 'Revelation'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final bible = ref.read(bibleProvider).valueOrNull;
    
    if (bible == null || query.isEmpty) {
      setState(() => _filteredBooks = []);
      return;
    }
    
    // Parse reference like "John 3" or "Gen 1:1"
    final parts = query.split(RegExp(r'[\s:]'));
    final bookQuery = parts.first;
    
    setState(() {
      _filteredBooks = bible.books.where((book) {
        return book.name.toLowerCase().startsWith(bookQuery) ||
               _getAbbreviation(book.name).toLowerCase().startsWith(bookQuery);
      }).take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bibleAsync = ref.watch(bibleProvider);
    
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.bolt_rounded, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  'Quick Jump',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Search input
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Type "John 3" or "Gen 1:1"...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _selectedBook = null);
                        },
                      )
                    : null,
              ),
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => _handleSubmit(),
            ),
            const SizedBox(height: 16),
            
            // Results or chapter grid
            Flexible(
              child: _selectedBook != null
                  ? _buildChapterGrid(_selectedBook!)
                  : _filteredBooks.isNotEmpty
                      ? _buildBookResults()
                      : _buildPopularBooks(bibleAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookResults() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _filteredBooks.length,
      itemBuilder: (context, index) {
        final book = _filteredBooks[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _getAbbreviation(book.name),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          title: Text(book.name),
          subtitle: Text('${book.chapterCount} chapters'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => setState(() => _selectedBook = book),
        );
      },
    );
  }

  Widget _buildChapterGrid(Book book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button and book name
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _selectedBook = null),
            ),
            Text(
              book.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Chapter grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: book.chapterCount,
            itemBuilder: (context, index) {
              final chapter = index + 1;
              return GestureDetector(
                onTap: () => _navigateToChapter(book.id, chapter, book.name),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$chapter',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularBooks(AsyncValue<Bible> bibleAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: bibleAsync.when(
            data: (bible) => _popularBooks.map((name) {
              final book = bible.getBookByName(name);
              if (book == null) return const SizedBox.shrink();
              return ActionChip(
                avatar: Icon(
                  Icons.menu_book,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: Text(name),
                onPressed: () => setState(() => _selectedBook = book),
              );
            }).toList(),
            loading: () => [const CircularProgressIndicator()],
            error: (_, __) => [const Text('Error loading')],
          ),
        ),
      ],
    );
  }

  String _getAbbreviation(String name) {
    final abbr = {
      'Genesis': 'Gen', 'Exodus': 'Exo', 'Psalms': 'Ps',
      'Proverbs': 'Prov', 'Matthew': 'Matt', 'Mark': 'Mark',
      'Luke': 'Luke', 'John': 'John', 'Acts': 'Acts',
      'Romans': 'Rom', 'Revelation': 'Rev',
    };
    return abbr[name] ?? name.substring(0, 3);
  }

  void _handleSubmit() {
    if (_filteredBooks.isNotEmpty) {
      setState(() => _selectedBook = _filteredBooks.first);
    }
  }

  void _navigateToChapter(int bookId, int chapter, String bookName) {
    Navigator.pop(context);
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
