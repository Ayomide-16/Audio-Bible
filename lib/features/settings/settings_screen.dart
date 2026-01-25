import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/theme_provider.dart';
import '../download/download_service.dart';

/// Navigation style enum
enum NavigationStyle { honeycomb, list, grid }

/// Navigation style provider
final navigationStyleProvider = StateNotifierProvider<NavigationStyleNotifier, NavigationStyle>((ref) {
  return NavigationStyleNotifier();
});

class NavigationStyleNotifier extends StateNotifier<NavigationStyle> {
  NavigationStyleNotifier() : super(NavigationStyle.honeycomb) {
    _loadPreference();
  }

  static const String _key = 'navigation_style';

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key);
    if (index != null && index < NavigationStyle.values.length) {
      state = NavigationStyle.values[index];
    }
  }

  Future<void> setStyle(NavigationStyle style) async {
    state = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, style.index);
  }
}

/// Font size provider
final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier();
});

class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(18.0) {
    _loadPreference();
  }

  static const String _key = 'font_size';

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final size = prefs.getDouble(_key);
    if (size != null) {
      state = size;
    }
  }

  Future<void> setSize(double size) async {
    state = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, size);
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isAudioDownloaded = false;
  int _audioSize = 0;
  String _usbPath = '';

  @override
  void initState() {
    super.initState();
    _checkAudioStatus();
    _loadUsbPath();
  }

  Future<void> _checkAudioStatus() async {
    final downloaded = await DownloadService.isAudioDownloaded();
    final size = await DownloadService.getDownloadedSize();
    setState(() {
      _isAudioDownloaded = downloaded;
      _audioSize = size;
    });
  }

  Future<void> _loadUsbPath() async {
    final path = await DownloadService.getUsbTransferPath();
    setState(() => _usbPath = path);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final navStyle = ref.watch(navigationStyleProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.surfaceLight,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildCard([
            _buildListTile(
              title: 'Theme',
              subtitle: _getThemeLabel(themeMode),
              leading: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppColors.primary,
              ),
              trailing: _buildSegmentedControl<ThemeMode>(
                value: themeMode,
                options: ThemeMode.values,
                labels: ['System', 'Light', 'Dark'],
                onChanged: (mode) => ref.read(themeModeProvider.notifier).setMode(mode),
              ),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Navigation Section
          _buildSectionHeader('Navigation'),
          _buildCard([
            _buildListTile(
              title: 'Navigation Style',
              subtitle: _getNavStyleLabel(navStyle),
              leading: Icon(
                _getNavStyleIcon(navStyle),
                color: AppColors.primary,
              ),
              trailing: _buildSegmentedControl<NavigationStyle>(
                value: navStyle,
                options: NavigationStyle.values,
                labels: ['Honeycomb', 'List', 'Grid'],
                onChanged: (style) => ref.read(navigationStyleProvider.notifier).setStyle(style),
              ),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Reading Section
          _buildSectionHeader('Reading'),
          _buildCard([
            _buildListTile(
              title: 'Font Size',
              subtitle: '${fontSize.toInt()}pt',
              leading: const Icon(Icons.format_size_rounded, color: AppColors.primary),
              trailing: SizedBox(
                width: 160,
                child: Slider(
                  value: fontSize,
                  min: 14,
                  max: 32,
                  divisions: 9,
                  onChanged: (value) {
                    ref.read(fontSizeProvider.notifier).setSize(value);
                  },
                ),
              ),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Audio Files Section
          _buildSectionHeader('Audio Files'),
          _buildCard([
            _buildListTile(
              title: 'Audio Status',
              subtitle: _isAudioDownloaded 
                  ? 'Downloaded (${(_audioSize / 1024 / 1024).toStringAsFixed(1)} MB)'
                  : 'Not downloaded',
              leading: Icon(
                _isAudioDownloaded ? Icons.check_circle_rounded : Icons.download_rounded,
                color: _isAudioDownloaded ? AppColors.success : AppColors.primary,
              ),
              trailing: _isAudioDownloaded
                  ? TextButton(
                      onPressed: _showDeleteConfirmation,
                      child: Text(
                        'Delete',
                        style: TextStyle(color: AppColors.error),
                      ),
                    )
                  : TextButton(
                      onPressed: _navigateToDownload,
                      child: const Text('Download'),
                    ),
            ),
            const Divider(height: 1, indent: 56),
            _buildListTile(
              title: 'USB Transfer',
              subtitle: 'Transfer audio files manually',
              leading: const Icon(Icons.usb_rounded, color: AppColors.primary),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _showUsbInstructions,
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // About Section
          _buildSectionHeader('About'),
          _buildCard([
            _buildListTile(
              title: 'Audio Bible',
              subtitle: 'Version 1.0.0',
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/icon.png', width: 32, height: 32),
              ),
            ),
          ]),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSegmentedControl<T>({
    required T value,
    required List<T> options,
    required List<String> labels,
    required ValueChanged<T> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (index) {
          final isSelected = value == options[index];
          return GestureDetector(
            onTap: () => onChanged(options[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected 
                    ? (isDark ? AppColors.primaryDark : AppColors.primary)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follow system';
      case ThemeMode.light:
        return 'Always light';
      case ThemeMode.dark:
        return 'Always dark';
    }
  }

  String _getNavStyleLabel(NavigationStyle style) {
    switch (style) {
      case NavigationStyle.honeycomb:
        return 'Honeycomb pattern';
      case NavigationStyle.list:
        return 'Expandable list';
      case NavigationStyle.grid:
        return 'Book grid';
    }
  }

  IconData _getNavStyleIcon(NavigationStyle style) {
    switch (style) {
      case NavigationStyle.honeycomb:
        return Icons.hexagon_rounded;
      case NavigationStyle.list:
        return Icons.list_rounded;
      case NavigationStyle.grid:
        return Icons.grid_view_rounded;
    }
  }

  void _navigateToDownload() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Download Screen')),
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
          'This will remove all downloaded audio files. '
          'You can download them again or transfer via USB.',
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
              _checkAudioStatus();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Audio files deleted')),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showUsbInstructions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.cardDark
              : AppColors.cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.usb_rounded, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'USB Transfer Instructions',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInstructionStep(
              '1',
              'Connect your phone to computer via USB cable',
            ),
            _buildInstructionStep(
              '2',
              'On your phone, select "File Transfer" mode',
            ),
            _buildInstructionStep(
              '3',
              'Navigate to this folder on your phone:',
              subtitle: _usbPath,
            ),
            _buildInstructionStep(
              '4',
              'Copy audio files with this structure:\n'
              '• Genesis/1.mp3, 2.mp3...\n'
              '• Exodus/1.mp3, 2.mp3...\n'
              '• [BookName]/[Chapter].mp3',
            ),
            _buildInstructionStep(
              '5',
              'Restart the app to detect the files',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
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
                  text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
