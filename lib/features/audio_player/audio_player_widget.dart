import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bible_models.dart';
import '../../core/theme/app_theme.dart';

// Placeholder for actual audio service
// TODO: Implement with just_audio package

/// Provider for playback state
final isPlayingProvider = StateProvider<bool>((ref) => false);
final playbackProgressProvider = StateProvider<double>((ref) => 0.0);
final playbackSpeedProvider = StateProvider<double>((ref) => 1.0);

class AudioPlayerWidget extends ConsumerStatefulWidget {
  final Chapter chapter;

  const AudioPlayerWidget({
    super.key,
    required this.chapter,
  });

  @override
  ConsumerState<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends ConsumerState<AudioPlayerWidget> {
  Duration _duration = const Duration(minutes: 5); // Placeholder
  Duration _position = Duration.zero;

  @override
  Widget build(BuildContext context) {
    final isPlaying = ref.watch(isPlayingProvider);
    final playbackSpeed = ref.watch(playbackSpeedProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Chapter title
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.chapter.bookName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    Text(
                      'Chapter ${widget.chapter.chapter}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              // Speed control
              _buildSpeedButton(context, playbackSpeed),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress bar
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    setState(() => _position = Duration(seconds: value.toInt()));
                    // TODO: Seek audio
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous chapter
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded),
                iconSize: 32,
                onPressed: () {
                  // TODO: Previous chapter
                },
              ),
              
              // Rewind 10s
              IconButton(
                icon: const Icon(Icons.replay_10_rounded),
                iconSize: 28,
                onPressed: () {
                  final newPos = _position.inSeconds - 10;
                  setState(() => _position = Duration(seconds: newPos.clamp(0, _duration.inSeconds)));
                },
              ),
              
              // Play/Pause
              Container(
                width: 64,
                height: 64,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(isPlayingProvider.notifier).state = !isPlaying;
                    // TODO: Toggle audio playback
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 36,
                  ),
                ),
              ),
              
              // Forward 10s
              IconButton(
                icon: const Icon(Icons.forward_10_rounded),
                iconSize: 28,
                onPressed: () {
                  final newPos = _position.inSeconds + 10;
                  setState(() => _position = Duration(seconds: newPos.clamp(0, _duration.inSeconds)));
                },
              ),
              
              // Next chapter
              IconButton(
                icon: const Icon(Icons.skip_next_rounded),
                iconSize: 32,
                onPressed: () {
                  // TODO: Next chapter
                },
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Additional controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () {
                  _showSleepTimerDialog(context);
                },
                icon: const Icon(Icons.bedtime_outlined, size: 20),
                label: const Text('Sleep Timer'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // TODO: Show playlist/chapter list
                },
                icon: const Icon(Icons.playlist_play, size: 20),
                label: const Text('Chapters'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedButton(BuildContext context, double speed) {
    return PopupMenuButton<double>(
      initialValue: speed,
      onSelected: (value) {
        ref.read(playbackSpeedProvider.notifier).state = value;
        // TODO: Set audio playback speed
      },
      itemBuilder: (context) => [
        for (final s in [0.5, 0.75, 1.0, 1.25, 1.5, 2.0])
          PopupMenuItem(
            value: s,
            child: Text('${s}x'),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '${speed}x',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showSleepTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sleep Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final minutes in [5, 10, 15, 30, 45, 60])
              ListTile(
                title: Text('$minutes minutes'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Set sleep timer
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sleep timer set for $minutes minutes')),
                  );
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
