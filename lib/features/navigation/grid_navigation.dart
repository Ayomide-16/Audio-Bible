import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/bible_models.dart';
import '../../core/theme/app_theme.dart';

class ListNavigation extends StatefulWidget {
  final Bible bible;
  final Function(int bookId, int chapter, String bookName) onChapterSelected;

  const ListNavigation({
    super.key,
    required this.bible,
    required this.onChapterSelected,
  });

  @override
  State<ListNavigation> createState() => _ListNavigationState();
}

class _ListNavigationState extends State<ListNavigation> {
  Book? _selectedBook;
  bool _showOldTestament = true;
  bool _showNewTestament = true;

  List<Book> get _oldTestament => widget.bible.books.where((b) => b.id <= 39).toList();
  List<Book> get _newTestament => widget.bible.books.where((b) => b.id > 39).toList();

  @override
  Widget build(BuildContext context) {
    if (_selectedBook != null) {
      return _buildChapterGrid();
    }
    return _buildBooksList();
  }

  Widget _buildBooksList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20), // Uniform margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a Book',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.bible.books.length} books in the Bible',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: ListView(
              children: [
                // Old Testament Section
                _buildSectionHeader(
                  title: 'Old Testament',
                  count: _oldTestament.length,
                  isExpanded: _showOldTestament,
                  onTap: () => setState(() => _showOldTestament = !_showOldTestament),
                  color: AppColors.honeycombColors[0], // Blue
                ),
                if (_showOldTestament)
                  _buildBooksSection(_oldTestament, isDark, AppColors.honeycombColors[0]),
                
                const SizedBox(height: 16),
                
                // New Testament Section
                _buildSectionHeader(
                  title: 'New Testament',
                  count: _newTestament.length,
                  isExpanded: _showNewTestament,
                  onTap: () => setState(() => _showNewTestament = !_showNewTestament),
                  color: AppColors.honeycombColors[6], // Green
                ),
                if (_showNewTestament)
                  _buildBooksSection(_newTestament, isDark, AppColors.honeycombColors[6]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required bool isExpanded,
    required VoidCallback onTap,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color.withOpacity(isDark ? 0.25 : 0.15),
              color.withOpacity(isDark ? 0.1 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.chevron_right_rounded,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksSection(List<Book> books, bool isDark, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        child: Column(
          children: books.asMap().entries.map((entry) {
            final index = entry.key;
            final book = entry.value;
            final isLast = index == books.length - 1;
            
            return Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    width: 40,
                    height: 40,
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
                        '${book.id}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    book.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
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
                if (!isLast)
                  Divider(
                    height: 0.5,
                    indent: 72,
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
              ],
            );
          }).toList(),
        ),
      ).animate().fadeIn(),
    );
  }

  Widget _buildChapterGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOldTestament = _selectedBook!.id <= 39;
    final color = isOldTestament ? AppColors.honeycombColors[0] : AppColors.honeycombColors[6];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      '${_selectedBook!.chapterCount} chapters • ${isOldTestament ? "Old" : "New"} Testament',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
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
