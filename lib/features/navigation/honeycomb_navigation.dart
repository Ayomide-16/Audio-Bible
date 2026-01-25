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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(20), // Uniform 20px margin on all sides
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Select a Letter',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a letter to browse books',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          
          // Honeycomb Grid - Centered with uniform spacing
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10, // Horizontal spacing between hexagons
                  runSpacing: 8, // Vertical spacing between rows
                  children: letters.asMap().entries.map((entry) {
                    final index = entry.key;
                    final letter = entry.value;
                    final bookCount = LetterBooks.letterMap[letter]?.length ?? 0;
                    final color = AppColors.honeycombColors[index % AppColors.honeycombColors.length];
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedLetter = letter);
                      },
                      child: _HexagonTile(
                        letter: letter,
                        bookCount: bookCount,
                        color: color,
                        isDark: isDark,
                        delay: index * 40,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final letterIndex = LetterBooks.letters.indexOf(_selectedLetter!);
    final color = AppColors.honeycombColors[letterIndex % AppColors.honeycombColors.length];

    return Padding(
      padding: const EdgeInsets.all(20), // Uniform margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and header
          Row(
            children: [
              _buildBackButton(onPressed: () => setState(() => _selectedLetter = null)),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _selectedLetter!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Books starting with "$_selectedLetter"',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      '${books.length} books',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Books list
          Expanded(
            child: ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 0.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withOpacity(0.2),
                            color.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          book.name.substring(0, 1),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      book.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${book.chapterCount} chapters',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    onTap: () => setState(() => _selectedBook = book),
                  ),
                ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final letterIndex = _selectedLetter != null 
        ? LetterBooks.letters.indexOf(_selectedLetter!) 
        : 0;
    final color = AppColors.honeycombColors[letterIndex % AppColors.honeycombColors.length];

    return Padding(
      padding: const EdgeInsets.all(20), // Uniform margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and header
          Row(
            children: [
              _buildBackButton(onPressed: () => setState(() => _selectedBook = null)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedBook!.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      '${_selectedBook!.chapterCount} chapters',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Chapter grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _selectedBook!.chapterCount,
              itemBuilder: (context, index) {
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withOpacity(isDark ? 0.3 : 0.15),
                          color.withOpacity(isDark ? 0.2 : 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$chapter',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: isDark ? color.withOpacity(0.9) : color,
                        ),
                      ),
                    ),
                  ),
                ).animate(delay: (index * 15).ms).fadeIn().scale(begin: const Offset(0.8, 0.8));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton({required VoidCallback onPressed}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          size: 20,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
    );
  }
}

/// Beautiful hexagon tile with gradient and shadow
class _HexagonTile extends StatefulWidget {
  final String letter;
  final int bookCount;
  final Color color;
  final bool isDark;
  final int delay;

  const _HexagonTile({
    required this.letter,
    required this.bookCount,
    required this.color,
    required this.isDark,
    required this.delay,
  });

  @override
  State<_HexagonTile> createState() => _HexagonTileState();
}

class _HexagonTileState extends State<_HexagonTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: 68,
          height: 78,
          child: CustomPaint(
            painter: _HexagonPainter(
              color: widget.color,
              isDark: widget.isDark,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.letter,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black26,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${widget.bookCount}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate(delay: widget.delay.ms).fadeIn().scale(begin: const Offset(0.5, 0.5));
  }
}

class _HexagonPainter extends CustomPainter {
  final Color color;
  final bool isDark;

  _HexagonPainter({required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createHexagonPath(size);
    
    // Shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 4, true);
    
    // Gradient fill
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color,
          Color.lerp(color, Colors.black, 0.2)!,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
    
    // Subtle highlight on top
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height / 2));
    canvas.drawPath(path, highlightPaint);
    
    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  Path _createHexagonPath(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radiusX = size.width / 2 * 0.92;
    final radiusY = size.height / 2 * 0.92;

    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final x = centerX + radiusX * math.cos(angle);
      final y = centerY + radiusY * math.sin(angle);
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
