import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/bible_models.dart';
import '../../core/theme/app_theme.dart';

class GridNavigation extends StatefulWidget {
  final Bible bible;
  final Function(int bookId, int chapter, String bookName) onChapterSelected;

  const GridNavigation({
    super.key,
    required this.bible,
    required this.onChapterSelected,
  });

  @override
  State<GridNavigation> createState() => _GridNavigationState();
}

class _GridNavigationState extends State<GridNavigation> {
  Book? _selectedBook;

  @override
  Widget build(BuildContext context) {
    if (_selectedBook != null) {
      return _buildChapterGrid();
    }
    return _buildBooksGrid();
  }

  Widget _buildBooksGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Books',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.bible.books.asMap().entries.map((entry) {
              final index = entry.key;
              final book = entry.value;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedBook = book),
                child: Container(
                  width: 90,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: book.testament == 'OT' 
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: book.testament == 'OT'
                          ? AppColors.primary.withOpacity(0.3)
                          : AppColors.accent.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getAbbreviation(book.name),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: book.testament == 'OT'
                              ? AppColors.primary
                              : AppColors.accentDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${book.chapterCount} ch',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: (index * 20).ms).fadeIn().scale(begin: const Offset(0.9, 0.9));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _selectedBook = null),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Text(
                _selectedBook!.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_selectedBook!.chapterCount, (index) {
              final chapter = index + 1;
              return GestureDetector(
                onTap: () {
                  widget.onChapterSelected(
                    _selectedBook!.id,
                    chapter,
                    _selectedBook!.name,
                  );
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
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
              ).animate(delay: (index * 15).ms).fadeIn();
            }),
          ),
        ],
      ),
    );
  }

  String _getAbbreviation(String name) {
    final abbr = {
      'Genesis': 'Gen', 'Exodus': 'Exo', 'Leviticus': 'Lev',
      'Numbers': 'Num', 'Deuteronomy': 'Deut', 'Joshua': 'Josh',
      'Judges': 'Judg', 'Ruth': 'Ruth', '1 Samuel': '1 Sam',
      '2 Samuel': '2 Sam', '1 Kings': '1 Kgs', '2 Kings': '2 Kgs',
      '1 Chronicles': '1 Chr', '2 Chronicles': '2 Chr', 'Ezra': 'Ezra',
      'Nehemiah': 'Neh', 'Esther': 'Esth', 'Job': 'Job',
      'Psalms': 'Ps', 'Proverbs': 'Prov', 'Ecclesiastes': 'Eccl',
      'Song of Solomon': 'Song', 'Isaiah': 'Isa', 'Jeremiah': 'Jer',
      'Lamentations': 'Lam', 'Ezekiel': 'Ezek', 'Daniel': 'Dan',
      'Hosea': 'Hos', 'Joel': 'Joel', 'Amos': 'Amos',
      'Obadiah': 'Obad', 'Jonah': 'Jon', 'Micah': 'Mic',
      'Nahum': 'Nah', 'Habakkuk': 'Hab', 'Zephaniah': 'Zeph',
      'Haggai': 'Hag', 'Zechariah': 'Zech', 'Malachi': 'Mal',
      'Matthew': 'Matt', 'Mark': 'Mark', 'Luke': 'Luke',
      'John': 'John', 'Acts': 'Acts', 'Romans': 'Rom',
      '1 Corinthians': '1 Cor', '2 Corinthians': '2 Cor',
      'Galatians': 'Gal', 'Ephesians': 'Eph', 'Philippians': 'Phil',
      'Colossians': 'Col', '1 Thessalonians': '1 Thes',
      '2 Thessalonians': '2 Thes', '1 Timothy': '1 Tim',
      '2 Timothy': '2 Tim', 'Titus': 'Titus', 'Philemon': 'Phlm',
      'Hebrews': 'Heb', 'James': 'Jas', '1 Peter': '1 Pet',
      '2 Peter': '2 Pet', '1 John': '1 Jn', '2 John': '2 Jn',
      '3 John': '3 Jn', 'Jude': 'Jude', 'Revelation': 'Rev',
    };
    return abbr[name] ?? name.substring(0, 3);
  }
}
