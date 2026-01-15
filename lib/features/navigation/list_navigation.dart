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
  bool _otExpanded = false;
  bool _ntExpanded = false;
  Book? _selectedBook;

  @override
  Widget build(BuildContext context) {
    if (_selectedBook != null) {
      return _buildChapterGrid();
    }
    return _buildBooksList();
  }

  Widget _buildBooksList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Old Testament
          _buildTestamentSection(
            'Old Testament',
            widget.bible.oldTestament,
            _otExpanded,
            () => setState(() => _otExpanded = !_otExpanded),
          ),
          const SizedBox(height: 8),
          // New Testament
          _buildTestamentSection(
            'New Testament',
            widget.bible.newTestament,
            _ntExpanded,
            () => setState(() => _ntExpanded = !_ntExpanded),
          ),
        ],
      ),
    );
  }

  Widget _buildTestamentSection(
    String title,
    List<Book> books,
    bool isExpanded,
    VoidCallback onToggle,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${books.length} books'),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: onToggle,
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            ...books.map((book) => ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  '${book.id}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(book.name),
              trailing: Text(
                '${book.chapterCount} ch',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () => setState(() => _selectedBook = book),
            )),
          ],
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
}
