import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/main_shell.dart';
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
  bool _showDownloadScreen = false;

  @override
  void initState() {
    super.initState();
    _checkAudioStatus();
  }

  Future<void> _checkAudioStatus() async {
    // Check if audio is already downloaded
    final audioDownloaded = await DownloadService.isAudioDownloaded();
    
    // If audio is downloaded, go directly to main app
    if (audioDownloaded) {
      setState(() {
        _showDownloadScreen = false;
        _isLoading = false;
      });
      return;
    }
    
    // Check if user has already seen and skipped the download prompt
    final hasSeenPrompt = await DownloadService.hasSeenDownloadPrompt();
    
    // Only show download screen on FIRST launch when audio is not downloaded
    // After user skips, never show again automatically
    setState(() {
      _showDownloadScreen = !hasSeenPrompt;
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
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/icon.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    // Show download screen only on first launch when audio not downloaded
    if (_showDownloadScreen) {
      return DownloadScreen(
        onComplete: () {
          setState(() => _showDownloadScreen = false);
        },
        onSkip: () async {
          // Mark prompt as seen so it won't show again
          await DownloadService.markDownloadPromptSeen();
          setState(() => _showDownloadScreen = false);
        },
      );
    }

    // Show main app with bottom navigation
    return const MainShell();
  }
}
