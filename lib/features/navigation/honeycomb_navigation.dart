import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/bible_models.dart';
import '../../core/theme/app_theme.dart';
import 'dart:math' as math;

/// Letter to books mapping for honeycomb navigation
class LetterBooks {
  static final Map<String, List<String>> letterMap = {
    'A': ['Acts', 'Amos'],
    'C': ['1 Chronicles', '2 Chronicles', 'Colossians', '1 Corinthians', '2 Corinthians'],
    'D': ['Daniel', 'Deuteronomy'],
    'E': ['Ecclesiastes', 'Ephesians', 'Esther', 'Exodus', 'Ezekiel', 'Ezra'],
    'G': ['Galatians', 'Genesis'],
    'H': ['Habakkuk', 'Haggai', 'Hebrews', 'Hosea'],
    'I': ['Isaiah'],
    'J': ['James', 'Jeremiah', 'Job', 'Joel', 'John', '1 John', '2 John', '3 John', 'Jonah', 'Joshua', 'Jude', 'Judges'],
    'K': ['1 Kings', '2 Kings'],
    'L': ['Lamentations', 'Leviticus', 'Luke'],
    'M': ['Malachi', 'Mark', 'Matthew', 'Micah'],
    'N': ['Nahum', 'Nehemiah', 'Numbers'],
    'O': ['Obadiah'],
    'P': ['1 Peter', '2 Peter', 'Philemon', 'Philippians', 'Proverbs', 'Psalms'],
    'R': ['Revelation', 'Romans', 'Ruth'],
    'S': ['1 Samuel', '2 Samuel', 'Song of Solomon'],
    'T': ['1 Thessalonians', '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus'],
    'Z': ['Zechariah', 'Zephaniah'],
  };

  static List<String> get letters => letterMap.keys.toList();
}

class HoneycombNavigation extends StatefulWidget {
  final Bible bible;
  final Function(int bookId, int chapter, String bookName) onChapterSelected;

  const HoneycombNavigation({
    super.key,
    required this.bible,
    required this.onChapterSelected,
  });

  @override
  State<HoneycombNavigation> createState() => _HoneycombNavigationState();
}

class _HoneycombNavigationState extends State<HoneycombNavigation> {
  String? _selectedLetter;
  Book? _selectedBook;

  @override
  Widget build(BuildContext context) {
    if (_selectedBook != null) {
      return _buildChapterGrid();
    }
    if (_selectedLetter != null) {
      return _buildBooksList();
    }
    return _buildHoneycomb();
  }

  Widget _buildHoneycomb() {
    final letters = LetterBooks.letters;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a Letter',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: letters.asMap().entries.map((entry) {
              final index = entry.key;
              final letter = entry.value;
              final bookCount = LetterBooks.letterMap[letter]?.length ?? 0;
              
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedLetter = letter);
                },
                child: _HexagonTile(
                  letter: letter,
                  bookCount: bookCount,
                  delay: index * 30,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList() {
    final bookNames = LetterBooks.letterMap[_selectedLetter] ?? [];
    final books = bookNames
        .map((name) => widget.bible.getBookByName(name))
        .whereType<Book>()
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and title
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _selectedLetter = null),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Text(
                'Books starting with "$_selectedLetter"',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Books list
          ...books.asMap().entries.map((entry) {
            final index = entry.key;
            final book = entry.value;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    book.name.substring(0, 1),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(book.name),
                subtitle: Text('${book.chapterCount} chapters'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => setState(() => _selectedBook = book),
              ),
            ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.2);
          }),
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
          // Back button and title
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _selectedBook = null),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Text(
                  _selectedBook!.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${_selectedBook!.chapterCount} chapters',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chapter grid
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
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$chapter',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ).animate(delay: (index * 20).ms).fadeIn().scale(begin: const Offset(0.8, 0.8));
            }),
          ),
        ],
      ),
    );
  }
}

/// Hexagon tile widget for honeycomb
class _HexagonTile extends StatelessWidget {
  final String letter;
  final int bookCount;
  final int delay;

  const _HexagonTile({
    required this.letter,
    required this.bookCount,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 80,
      child: CustomPaint(
        painter: _HexagonPainter(
          color: AppColors.primary,
          isDark: Theme.of(context).brightness == Brightness.dark,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                letter,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '$bookCount',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: delay.ms).fadeIn().scale(begin: const Offset(0.5, 0.5));
  }
}

class _HexagonPainter extends CustomPainter {
  final Color color;
  final bool isDark;

  _HexagonPainter({required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color,
          color.withOpacity(0.7),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = _createHexagonPath(size);
    canvas.drawPath(path, paint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  Path _createHexagonPath(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(size.width, size.height) / 2 * 0.95;

    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
