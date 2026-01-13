import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bible_models.dart';
import '../../core/theme/app_theme.dart';
import '../reader/reader_screen.dart';

/// AI search query state
final aiSearchQueryProvider = StateProvider<String>((ref) => '');
final aiSearchLoadingProvider = StateProvider<bool>((ref) => false);
final aiSearchResultsProvider = StateProvider<List<AISearchResult>>((ref) => []);

/// AI Search result model
class AISearchResult {
  final Verse verse;
  final double relevanceScore;
  final String? explanation;

  AISearchResult({
    required this.verse,
    required this.relevanceScore,
    this.explanation,
  });
}

class AISearchScreen extends ConsumerStatefulWidget {
  const AISearchScreen({super.key});

  @override
  ConsumerState<AISearchScreen> createState() => _AISearchScreenState();
}

class _AISearchScreenState extends ConsumerState<AISearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(aiSearchLoadingProvider);
    final results = ref.watch(aiSearchResultsProvider);
    final query = ref.watch(aiSearchQueryProvider);

    return Column(
      children: [
        // Search input with AI styling
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accent.withOpacity(0.1),
                AppColors.primary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Ask anything about the Bible...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.auto_awesome, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: null,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _performSearch(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _buildSuggestionChip('stories about forgiveness'),
                          _buildSuggestionChip('overcoming fear'),
                          _buildSuggestionChip('God\'s promises'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isLoading ? null : _performSearch,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Results or placeholder
        Expanded(
          child: isLoading
              ? _buildLoadingState()
              : results.isEmpty
                  ? _buildEmptyState(query)
                  : _buildResultsList(results),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(
        text,
        style: TextStyle(fontSize: 11, color: AppColors.accent),
      ),
      backgroundColor: Colors.transparent,
      side: BorderSide(color: AppColors.accent.withOpacity(0.3)),
      padding: EdgeInsets.zero,
      onPressed: () {
        _searchController.text = text;
        ref.read(aiSearchQueryProvider.notifier).state = text;
        _performSearch();
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Searching the Scriptures...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Finding relevant passages for your query',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 72,
              color: AppColors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'AI-Powered Search',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Ask questions in natural language and find relevant Bible passages.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            _buildExampleQueries(),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleQueries() {
    final examples = [
      'What does the Bible say about love?',
      'Stories of faith in hard times',
      'How to find peace and comfort',
      'Jesus\' teachings on forgiveness',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Try asking:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...examples.map((example) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () {
              _searchController.text = example;
              ref.read(aiSearchQueryProvider.notifier).state = example;
              _performSearch();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: AppColors.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      example,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildResultsList(List<AISearchResult> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '${results.length} relevant passages found',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return _buildResultCard(result);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(AISearchResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToVerse(result.verse),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reference and relevance
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      result.verse.reference,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Relevance indicator
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        '${(result.relevanceScore * 100).toInt()}% match',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Verse text
              Text(
                result.verse.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              
              // AI explanation
              if (result.explanation != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline, size: 16, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          result.explanation!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.accent,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Actions
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _navigateToVerse(result.verse),
                    icon: const Icon(Icons.menu_book, size: 16),
                    label: const Text('Read Chapter'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 20),
                    onPressed: () {
                      // TODO: Share verse
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border, size: 20),
                    onPressed: () {
                      // TODO: Bookmark verse
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    ref.read(aiSearchQueryProvider.notifier).state = query;
    ref.read(aiSearchLoadingProvider.notifier).state = true;

    // TODO: Implement actual Gemini API call
    // For now, simulate with a delay and mock results
    await Future.delayed(const Duration(seconds: 2));

    // Mock results for demonstration
    // In production, this would call the Gemini API
    final mockResults = <AISearchResult>[
      // Results would come from AI semantic search
    ];

    ref.read(aiSearchResultsProvider.notifier).state = mockResults;
    ref.read(aiSearchLoadingProvider.notifier).state = false;

    // Show message that this is a placeholder
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI Search requires Gemini API integration. Use keyword search for now.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _navigateToVerse(Verse verse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderScreen(
          bookId: verse.bookId,
          chapterNumber: verse.chapter,
        ),
      ),
    );
  }
}
