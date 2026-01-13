import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/bible_repository.dart';
import '../../data/models/bible_models.dart';
import '../../core/theme/app_theme.dart';
import '../audio_player/audio_player_widget.dart';

/// Provider for current chapter
final currentChapterProvider = FutureProvider.family<Chapter?, ({int bookId, int chapter})>(
  (ref, params) async {
    final repo = BibleRepository();
    return repo.getChapter(params.bookId, params.chapter);
  },
);

/// Provider for current highlighted verse during audio playback
final highlightedVerseProvider = StateProvider<int?>((ref) => null);

class ReaderScreen extends ConsumerStatefulWidget {
  final int bookId;
  final int chapterNumber;

  const ReaderScreen({
    super.key,
    required this.bookId,
    required this.chapterNumber,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late int _currentChapter;
  double _fontSize = 18.0;
  final ScrollController _scrollController = ScrollController();
  bool _showAudioPlayer = false;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapterNumber;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(
      currentChapterProvider((bookId: widget.bookId, chapter: _currentChapter)),
    );
    final highlightedVerse = ref.watch(highlightedVerseProvider);

    return Scaffold(
      appBar: AppBar(
        title: chapterAsync.when(
          data: (chapter) => Text(chapter?.title ?? 'Loading...'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: _decreaseFontSize,
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: _increaseFontSize,
          ),
          IconButton(
            icon: Icon(_showAudioPlayer ? Icons.headset_off : Icons.headset),
            onPressed: () => setState(() => _showAudioPlayer = !_showAudioPlayer),
          ),
        ],
      ),
      body: Column(
        children: [
          // Audio Player (collapsible)
          if (_showAudioPlayer)
            chapterAsync.when(
              data: (chapter) => chapter != null
                  ? AudioPlayerWidget(chapter: chapter)
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          
          // Verse Content
          Expanded(
            child: chapterAsync.when(
              data: (chapter) => chapter != null
                  ? _buildVerseList(context, chapter, highlightedVerse)
                  : const Center(child: Text('Chapter not found')),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
          
          // Navigation
          chapterAsync.when(
            data: (chapter) => _buildNavigationBar(context, chapter),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseList(BuildContext context, Chapter chapter, int? highlightedVerse) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: chapter.verses.length,
      itemBuilder: (context, index) {
        final verse = chapter.verses[index];
        final isHighlighted = highlightedVerse == verse.verse;
        
        return GestureDetector(
          onTap: () {
            // TODO: Jump to audio position for this verse
            ref.read(highlightedVerseProvider.notifier).state = verse.verse;
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isHighlighted 
                  ? AppColors.verseHighlight 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  // Verse number
                  TextSpan(
                    text: '${verse.verse} ',
                    style: TextStyle(
                      fontSize: _fontSize * 0.75,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  // Verse text
                  TextSpan(
                    text: verse.text,
                    style: TextStyle(
                      fontSize: _fontSize,
                      height: 1.6,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontFamily: 'Lora',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationBar(BuildContext context, Chapter? chapter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous chapter
          TextButton.icon(
            onPressed: _currentChapter > 1 ? _previousChapter : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Previous'),
            style: TextButton.styleFrom(
              foregroundColor: _currentChapter > 1 
                  ? AppColors.primary 
                  : Colors.grey,
            ),
          ),
          
          // Chapter indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Chapter $_currentChapter',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          
          // Next chapter
          TextButton.icon(
            onPressed: _hasNextChapter(chapter) ? _nextChapter : null,
            icon: const Text('Next'),
            label: const Icon(Icons.chevron_right),
            style: TextButton.styleFrom(
              foregroundColor: _hasNextChapter(chapter) 
                  ? AppColors.primary 
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasNextChapter(Chapter? chapter) {
    // TODO: Get actual chapter count from book
    return true; // Simplified for now
  }

  void _previousChapter() {
    if (_currentChapter > 1) {
      setState(() => _currentChapter--);
      _scrollController.jumpTo(0);
    }
  }

  void _nextChapter() {
    setState(() => _currentChapter++);
    _scrollController.jumpTo(0);
  }

  void _increaseFontSize() {
    if (_fontSize < 32) {
      setState(() => _fontSize += 2);
    }
  }

  void _decreaseFontSize() {
    if (_fontSize > 14) {
      setState(() => _fontSize -= 2);
    }
  }
}
