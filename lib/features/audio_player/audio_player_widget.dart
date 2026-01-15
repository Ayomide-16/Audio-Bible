import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';

/// Provider for audio player state
final audioPlayerStateProvider = StateNotifierProvider<AudioPlayerStateNotifier, AudioPlayerState>((ref) {
  return AudioPlayerStateNotifier();
});

class AudioPlayerState {
  final bool isPlaying;
  final bool isVisible;
  final bool isExpanded;
  final String bookName;
  final int chapter;
  final Duration currentPosition;
  final Duration totalDuration;
  final double playbackSpeed;

  AudioPlayerState({
    this.isPlaying = false,
    this.isVisible = false,
    this.isExpanded = false,
    this.bookName = '',
    this.chapter = 1,
    this.currentPosition = Duration.zero,
    this.totalDuration = const Duration(minutes: 5),
    this.playbackSpeed = 1.0,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    bool? isVisible,
    bool? isExpanded,
    String? bookName,
    int? chapter,
    Duration? currentPosition,
    Duration? totalDuration,
    double? playbackSpeed,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isVisible: isVisible ?? this.isVisible,
      isExpanded: isExpanded ?? this.isExpanded,
      bookName: bookName ?? this.bookName,
      chapter: chapter ?? this.chapter,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }
}

class AudioPlayerStateNotifier extends StateNotifier<AudioPlayerState> {
  AudioPlayerStateNotifier() : super(AudioPlayerState());

  void play(String bookName, int chapter) {
    state = state.copyWith(
      isPlaying: true,
      isVisible: true,
      bookName: bookName,
      chapter: chapter,
    );
  }

  void pause() {
    state = state.copyWith(isPlaying: false);
  }

  void resume() {
    state = state.copyWith(isPlaying: true);
  }

  void stop() {
    state = state.copyWith(isPlaying: false, isVisible: false);
  }

  void toggleExpanded() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }

  void setPosition(Duration position) {
    state = state.copyWith(currentPosition: position);
  }

  void setDuration(Duration duration) {
    state = state.copyWith(totalDuration: duration);
  }

  void setSpeed(double speed) {
    state = state.copyWith(playbackSpeed: speed);
  }
}

/// Bottom audio player widget
class BottomAudioPlayer extends ConsumerWidget {
  const BottomAudioPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioPlayerStateProvider);

    if (!state.isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: state.isExpanded ? 180 : 64,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: state.isExpanded ? _buildExpandedPlayer(context, ref, state) : _buildCollapsedPlayer(context, ref, state),
    );
  }

  Widget _buildCollapsedPlayer(BuildContext context, WidgetRef ref, AudioPlayerState state) {
    return GestureDetector(
      onTap: () => ref.read(audioPlayerStateProvider.notifier).toggleExpanded(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Book and chapter
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${state.bookName} ${state.chapter}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatDuration(state.currentPosition)} / ${_formatDuration(state.totalDuration)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            // Play/pause button
            IconButton(
              onPressed: () {
                if (state.isPlaying) {
                  ref.read(audioPlayerStateProvider.notifier).pause();
                } else {
                  ref.read(audioPlayerStateProvider.notifier).resume();
                }
              },
              icon: Icon(
                state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 32,
              ),
            ),
            // Close button
            IconButton(
              onPressed: () => ref.read(audioPlayerStateProvider.notifier).stop(),
              icon: const Icon(Icons.close, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPlayer(BuildContext context, WidgetRef ref, AudioPlayerState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header with collapse button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.bookName} - Chapter ${state.chapter}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => ref.read(audioPlayerStateProvider.notifier).toggleExpanded(),
                    icon: const Icon(Icons.keyboard_arrow_down),
                  ),
                  IconButton(
                    onPressed: () => ref.read(audioPlayerStateProvider.notifier).stop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: state.currentPosition.inSeconds.toDouble(),
              min: 0,
              max: state.totalDuration.inSeconds.toDouble(),
              onChanged: (value) {
                ref.read(audioPlayerStateProvider.notifier).setPosition(Duration(seconds: value.toInt()));
              },
            ),
          ),
          // Time display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(state.currentPosition), style: Theme.of(context).textTheme.bodySmall),
                Text(_formatDuration(state.totalDuration), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Speed selector
              PopupMenuButton<double>(
                onSelected: (speed) => ref.read(audioPlayerStateProvider.notifier).setSpeed(speed),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0.5, child: Text('0.5x')),
                  const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                  const PopupMenuItem(value: 1.0, child: Text('1x')),
                  const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                  const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                  const PopupMenuItem(value: 2.0, child: Text('2x')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('${state.playbackSpeed}x'),
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.skip_previous_rounded)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.replay_10_rounded)),
              // Play/pause
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    if (state.isPlaying) {
                      ref.read(audioPlayerStateProvider.notifier).pause();
                    } else {
                      ref.read(audioPlayerStateProvider.notifier).resume();
                    }
                  },
                  icon: Icon(
                    state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.forward_10_rounded)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.skip_next_rounded)),
            ],
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
