import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'settings/settings_screen.dart';
import 'audio_player/audio_player_widget.dart';
import '../core/theme/app_theme.dart';

/// Provider for current navigation index
final currentNavIndexProvider = StateProvider<int>((ref) => 0);

/// Main shell with bottom navigation
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentNavIndexProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          IndexedStack(
            index: currentIndex,
            children: const [
              HomeScreen(),
              SearchScreen(),
              SettingsScreen(),
            ],
          ),
          // Bottom audio player
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomAudioPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(currentNavIndexProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
