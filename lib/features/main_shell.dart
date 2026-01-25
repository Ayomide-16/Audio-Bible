import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'settings/settings_screen.dart';
import 'audio_player/audio_player_widget.dart';
import '../core/theme/app_theme.dart';

/// Provider for current navigation index
final currentNavIndexProvider = StateProvider<int>((ref) => 0);

/// Main shell with bottom navigation - Apple-inspired design
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentNavIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Main content with bottom padding for audio player
          Positioned.fill(
            child: IndexedStack(
              index: currentIndex,
              children: const [
                HomeScreen(),
                SearchScreen(),
                SettingsScreen(),
              ],
            ),
          ),
          // Bottom audio player (only shows when playing)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomAudioPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 0,
                  currentIndex: currentIndex,
                  icon: Icons.book_outlined,
                  selectedIcon: Icons.book_rounded,
                  label: 'Read',
                  isDark: isDark,
                ),
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 1,
                  currentIndex: currentIndex,
                  icon: Icons.search_outlined,
                  selectedIcon: Icons.search_rounded,
                  label: 'Search',
                  isDark: isDark,
                ),
                _buildNavItem(
                  context: context,
                  ref: ref,
                  index: 2,
                  currentIndex: currentIndex,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings_rounded,
                  label: 'Settings',
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required WidgetRef ref,
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = index == currentIndex;
    final color = isSelected 
        ? (isDark ? AppColors.primaryDark : AppColors.primary)
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return GestureDetector(
      onTap: () => ref.read(currentNavIndexProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? AppColors.primaryDark.withOpacity(0.15) : AppColors.primary.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
