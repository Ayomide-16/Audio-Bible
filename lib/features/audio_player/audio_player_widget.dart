import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
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

/// Apple Music-inspired bottom audio player widget
class BottomAudioPlayer extends ConsumerWidget {
  const BottomAudioPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioPlayerStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!state.isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: state.isExpanded ? 200 : 72,
      margin: EdgeInsets.fromLTRB(
        state.isExpanded ? 0 : 12,
        0,
        state.isExpanded ? 0 : 12,
        state.isExpanded ? 0 : 88,
      ),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.cardDark.withOpacity(0.95)
            : AppColors.cardLight.withOpacity(0.95),
        borderRadius: state.isExpanded 
            ? const BorderRadius.vertical(top: Radius.circular(20))
            : BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: state.isExpanded 
            ? const BorderRadius.vertical(top: Radius.circular(20))
            : BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: state.isExpanded 
              ? _buildExpandedPlayer(context, ref, state, isDark) 
              : _buildCollapsedPlayer(context, ref, state, isDark),
        ),
      ),
    );
  }

  Widget _buildCollapsedPlayer(BuildContext context, WidgetRef ref, AudioPlayerState state, bool isDark) {
    final color = isDark ? AppColors.primaryDark : AppColors.primary;
    
    return GestureDetector(
      onTap: () => ref.read(audioPlayerStateProvider.notifier).toggleExpanded(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Album art / Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.headphones_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Book and chapter info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${state.bookName} ${state.chapter}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Progress bar mini
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: state.totalDuration.inSeconds > 0
                          ? state.currentPosition.inSeconds / state.totalDuration.inSeconds
                          : 0,
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Play/pause button
            GestureDetector(
              onTap: () {
                if (state.isPlaying) {
                  ref.read(audioPlayerStateProvider.notifier).pause();
                } else {
                  ref.read(audioPlayerStateProvider.notifier).resume();
                }
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPlayer(BuildContext context, WidgetRef ref, AudioPlayerState state, bool isDark) {
    final color = isDark ? AppColors.primaryDark : AppColors.primary;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.headphones_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${state.bookName} ${state.chapter}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Chapter ${state.chapter}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => ref.read(audioPlayerStateProvider.notifier).toggleExpanded(),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
              IconButton(
                onPressed: () => ref.read(audioPlayerStateProvider.notifier).stop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: state.currentPosition.inSeconds.toDouble(),
              min: 0,
              max: state.totalDuration.inSeconds.toDouble(),
              activeColor: color,
              inactiveColor: color.withOpacity(0.2),
              onChanged: (value) {
                ref.read(audioPlayerStateProvider.notifier).setPosition(Duration(seconds: value.toInt()));
              },
            ),
          ),
          // Time display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(state.currentPosition), style: Theme.of(context).textTheme.bodySmall),
                Text('-${_formatDuration(state.totalDuration - state.currentPosition)}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Speed selector
              _buildSpeedButton(context, ref, state, color),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.skip_previous_rounded, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.replay_10_rounded, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
              // Play/pause
              GestureDetector(
                onTap: () {
                  if (state.isPlaying) {
                    ref.read(audioPlayerStateProvider.notifier).pause();
                  } else {
                    ref.read(audioPlayerStateProvider.notifier).resume();
                  }
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.forward_10_rounded, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.skip_next_rounded, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedButton(BuildContext context, WidgetRef ref, AudioPlayerState state, Color color) {
    return PopupMenuButton<double>(
      onSelected: (speed) => ref.read(audioPlayerStateProvider.notifier).setSpeed(speed),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 0.5, child: Text('0.5x')),
        const PopupMenuItem(value: 0.75, child: Text('0.75x')),
        const PopupMenuItem(value: 1.0, child: Text('1.0x')),
        const PopupMenuItem(value: 1.25, child: Text('1.25x')),
        const PopupMenuItem(value: 1.5, child: Text('1.5x')),
        const PopupMenuItem(value: 2.0, child: Text('2.0x')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${state.playbackSpeed}x',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
