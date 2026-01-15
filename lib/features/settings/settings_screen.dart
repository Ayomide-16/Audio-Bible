import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../download/download_service.dart';
import '../download/download_screen.dart';

/// Navigation style enum
enum NavigationStyle { honeycomb, list, grid }

/// Provider for navigation style preference
final navigationStyleProvider = StateNotifierProvider<NavigationStyleNotifier, NavigationStyle>((ref) {
  return NavigationStyleNotifier();
});

class NavigationStyleNotifier extends StateNotifier<NavigationStyle> {
  NavigationStyleNotifier() : super(NavigationStyle.honeycomb) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final styleIndex = prefs.getInt('navigation_style') ?? 0;
    state = NavigationStyle.values[styleIndex];
  }

  Future<void> setStyle(NavigationStyle style) async {
    state = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('navigation_style', style.index);
  }
}

/// Provider for theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt('theme_mode') ?? 0;
    state = ThemeMode.values[modeIndex];
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }
}

/// Provider for font size
final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier();
});

class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(18.0) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble('font_size') ?? 18.0;
  }

  Future<void> setSize(double size) async {
    state = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', size);
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _audioDownloaded = false;
  int _audioSize = 0;
  bool _isCheckingAudio = true;

  @override
  void initState() {
    super.initState();
    _checkAudioStatus();
  }

  Future<void> _checkAudioStatus() async {
    final downloaded = await DownloadService.isAudioDownloaded();
    final size = await DownloadService.getDownloadedSize();
    setState(() {
      _audioDownloaded = downloaded;
      _audioSize = size;
      _isCheckingAudio = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navStyle = ref.watch(navigationStyleProvider);
    final fontSize = ref.watch(fontSizeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Navigation Section
          _buildSectionHeader('Navigation'),
          _buildNavigationStyleSelector(navStyle),
          const Divider(),

          // Audio Section
          _buildSectionHeader('Audio Files'),
          _buildAudioManagement(),
          const Divider(),

          // Reading Section
          _buildSectionHeader('Reading'),
          _buildFontSizeSlider(fontSize),
          _buildThemeSelector(),
          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          _buildAboutTile(),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNavigationStyleSelector(NavigationStyle currentStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Navigation Style'),
          const SizedBox(height: 12),
          SegmentedButton<NavigationStyle>(
            segments: const [
              ButtonSegment(
                value: NavigationStyle.honeycomb,
                label: Text('Honeycomb'),
                icon: Icon(Icons.hexagon_outlined),
              ),
              ButtonSegment(
                value: NavigationStyle.list,
                label: Text('List'),
                icon: Icon(Icons.list),
              ),
              ButtonSegment(
                value: NavigationStyle.grid,
                label: Text('Grid'),
                icon: Icon(Icons.grid_view),
              ),
            ],
            selected: {currentStyle},
            onSelectionChanged: (Set<NavigationStyle> selected) {
              ref.read(navigationStyleProvider.notifier).setStyle(selected.first);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAudioManagement() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isCheckingAudio)
            const Center(child: CircularProgressIndicator())
          else ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                _audioDownloaded ? Icons.check_circle : Icons.cloud_download,
                color: _audioDownloaded ? AppColors.success : AppColors.warning,
              ),
              title: Text(_audioDownloaded ? 'Audio Downloaded' : 'Audio Not Downloaded'),
              subtitle: Text(
                _audioDownloaded 
                    ? 'Size: ${(_audioSize / (1024 * 1024)).toStringAsFixed(0)} MB'
                    : 'Download size: ~830 MB',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _audioDownloaded ? null : _showDownloadDialog,
                    icon: const Icon(Icons.download),
                    label: Text(_audioDownloaded ? 'Downloaded' : 'Download Audio'),
                  ),
                ),
                if (_audioDownloaded) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _showDeleteConfirmation,
                    child: const Text('Delete'),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFontSizeSlider(double currentSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Font Size'),
              Text('${currentSize.toInt()}'),
            ],
          ),
          Slider(
            value: currentSize,
            min: 14,
            max: 28,
            divisions: 7,
            onChanged: (value) {
              ref.read(fontSizeProvider.notifier).setSize(value);
            },
          ),
          // Preview text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'For God so loved the world...',
              style: TextStyle(
                fontSize: currentSize,
                fontFamily: 'Lora',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.palette_outlined),
        title: const Text('Theme'),
        trailing: DropdownButton<ThemeMode>(
          value: ref.watch(themeModeProvider),
          onChanged: (ThemeMode? mode) {
            if (mode != null) {
              ref.read(themeModeProvider.notifier).setMode(mode);
            }
          },
          items: const [
            DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
            DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
            DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/icon.png', width: 40, height: 40),
        ),
        title: const Text('Audio Bible'),
        subtitle: const Text('Version 1.0.1 • KJV'),
        onTap: () {
          showAboutDialog(
            context: context,
            applicationName: 'Audio Bible',
            applicationVersion: '1.0.1',
            applicationIcon: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/icon.png', width: 60, height: 60),
            ),
            children: [
              const Text('King James Version Bible with audio playback.'),
            ],
          );
        },
      ),
    );
  }

  void _showDownloadDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => DownloadScreen(
          onComplete: () {
            Navigator.of(context).pop();
            _checkAudioStatus();
          },
          onSkip: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Audio Files?'),
        content: const Text(
          'This will remove all downloaded audio files (~830 MB). '
          'You can re-download them anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DownloadService.deleteAudioFiles();
              await _checkAudioStatus();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
