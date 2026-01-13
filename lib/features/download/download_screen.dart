import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import 'download_service.dart';

class DownloadScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const DownloadScreen({
    super.key,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _status = '';
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(flex: 1),
                
                // Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.headphones_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Audio Bible',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                
                const SizedBox(height: 12),
                
                // Subtitle
                Text(
                  'Download audio files for offline listening',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
                
                const SizedBox(height: 48),
                
                // Download info card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.library_music_rounded,
                        label: 'Complete KJV Audio',
                        value: '1,194 chapters',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.storage_rounded,
                        label: 'Download size',
                        value: '~830 MB',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.wifi_off_rounded,
                        label: 'Offline access',
                        value: 'Always available',
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 32),
                
                // Progress or buttons
                if (_isDownloading) ...[
                  _buildProgressSection(),
                ] else if (_error != null) ...[
                  _buildErrorSection(),
                ] else ...[
                  _buildButtonSection(),
                ],
                
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 12,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        // Status text
        Text(
          _status,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        // Percentage
        Text(
          '${(_progress * 100).toInt()}%',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _startDownload,
          child: const Text('Try Again'),
        ),
      ],
    );
  }

  Widget _buildButtonSection() {
    return Column(
      children: [
        // Download button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _startDownload,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download Audio Files'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 500.ms),
        
        const SizedBox(height: 16),
        
        // Skip button
        TextButton(
          onPressed: widget.onSkip,
          child: Text(
            'Skip for now (text only)',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }

  void _startDownload() {
    setState(() {
      _isDownloading = true;
      _error = null;
      _progress = 0.0;
    });

    DownloadService.downloadAudioFiles(
      onProgress: (progress, status) {
        setState(() {
          _progress = progress;
          _status = status;
        });
      },
      onComplete: () {
        widget.onComplete();
      },
      onError: (error) {
        setState(() {
          _isDownloading = false;
          _error = error;
        });
      },
    );
  }
}
