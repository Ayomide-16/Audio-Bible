import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/download/download_screen.dart';
import 'features/download/download_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AudioBibleApp()));
}

class AudioBibleApp extends ConsumerWidget {
  const AudioBibleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Audio Bible',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AppEntryPoint(),
    );
  }
}

/// Entry point that checks for audio download status
class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _isLoading = true;
  bool _audioDownloaded = false;
  bool _skipDownload = false;

  @override
  void initState() {
    super.initState();
    _checkAudioStatus();
  }

  Future<void> _checkAudioStatus() async {
    final downloaded = await DownloadService.isAudioDownloaded();
    setState(() {
      _audioDownloaded = downloaded;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    // Show download screen if audio not downloaded and not skipped
    if (!_audioDownloaded && !_skipDownload) {
      return DownloadScreen(
        onComplete: () {
          setState(() => _audioDownloaded = true);
        },
        onSkip: () {
          setState(() => _skipDownload = true);
        },
      );
    }

    // Show main app
    return const HomeScreen();
  }
}
