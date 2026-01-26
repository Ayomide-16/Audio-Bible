import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
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
  final int bookId;
  final int chapter;
  final Duration currentPosition;
  final Duration totalDuration;
  final double playbackSpeed;

  AudioPlayerState({
    this.isPlaying = false,
    this.isVisible = false,
    this.isExpanded = false,
    this.bookName = '',
    this.bookId = 1,
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
    int? bookId,
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
      bookId: bookId ?? this.bookId,
      chapter: chapter ?? this.chapter,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }
}

class AudioPlayerStateNotifier extends StateNotifier<AudioPlayerState> {
  AudioPlayerStateNotifier() : super(AudioPlayerState());

  void play(String bookName, int bookId, int chapter) {
    state = state.copyWith(
      isPlaying: true,
      isVisible: true,
      bookName: bookName,
      bookId: bookId,
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
    state = state.copyWith(isPlaying: false, isVisible: false, isExpanded: false);
  }

  void expand() {
    state = state.copyWith(isExpanded: true);
  }

  void collapse() {
    state = state.copyWith(isExpanded: false);
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
  
  void skipNext() {
    // Increment chapter (actual logic would check if chapter exists)
    state = state.copyWith(chapter: state.chapter + 1);
  }
  
  void skipPrevious() {
    if (state.chapter > 1) {
      state = state.copyWith(chapter: state.chapter - 1);
    }
  }
}

/// Apple Music-inspired bottom audio player with auto-collapse
class BottomAudioPlayer extends ConsumerStatefulWidget {
  const BottomAudioPlayer({super.key});

  @override
  ConsumerState<BottomAudioPlayer> createState() => _BottomAudioPlayerState();
}

class _BottomAudioPlayerState extends ConsumerState<BottomAudioPlayer> {
  Timer? _autoCollapseTimer;
  static const _autoCollapseDuration = Duration(seconds: 5);

  @override
  void dispose() {
    _autoCollapseTimer?.cancel();
    super.dispose();
  }

  void _resetAutoCollapseTimer() {
    _autoCollapseTimer?.cancel();
    final state = ref.read(audioPlayerStateProvider);
    if (state.isExpanded) {
      _autoCollapseTimer = Timer(_autoCollapseDuration, () {
        if (mounted) {
          ref.read(audioPlayerStateProvider.notifier).collapse();
        }
      });
    }
  }

  void _onUserInteraction() {
    _resetAutoCollapseTimer();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(audioPlayerStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Reset timer when expanded state changes
    ref.listen<AudioPlayerState>(audioPlayerStateProvider, (previous, next) {
      if (next.isExpanded && !(previous?.isExpanded ?? false)) {
        _resetAutoCollapseTimer();
      }
    });

    if (!state.isVisible) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _onUserInteraction,
      onPanDown: (_) => _onUserInteraction(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: state.isExpanded ? 240 : 68,
        margin: EdgeInsets.fromLTRB(
          state.isExpanded ? 0 : 12,
          0,
          state.isExpanded ? 0 : 12,
          state.isExpanded ? 0 : 8,
        ),
        decoration: BoxDecoration(
          color: isDark 
              ? AppColors.cardDark.withOpacity(0.98)
              : AppColors.cardLight.withOpacity(0.98),
          borderRadius: state.isExpanded 
              ? const BorderRadius.vertical(top: Radius.circular(24))
              : BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: state.isExpanded 
              ? const BorderRadius.vertical(top: Radius.circular(24))
              : BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: state.isExpanded 
                ? _buildExpandedPlayer(context, ref, state, isDark) 
                : _buildMiniPlayer(context, ref, state, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniPlayer(BuildContext context, WidgetRef ref, AudioPlayerState state, bool isDark) {
    final color = isDark ? AppColors.primaryDark : AppColors.primary;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ref.read(audioPlayerStateProvider.notifier).expand();
        _onUserInteraction();
      },
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
            _buildPlayPauseButton(ref, state, color, size: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPlayer(BuildContext context, WidgetRef ref, AudioPlayerState state, bool isDark) {
    final color = isDark ? AppColors.primaryDark : AppColors.primary;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar (drag to collapse)
          GestureDetector(
            onTap: () => ref.read(audioPlayerStateProvider.notifier).collapse(),
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header row
          Row(
            children: [
              // Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.headphones_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.bookName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chapter ${state.chapter}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Close button
              IconButton(
                onPressed: () {
                  ref.read(audioPlayerStateProvider.notifier).stop();
                },
                icon: Icon(Icons.close_rounded, color: secondaryColor),
                style: IconButton.styleFrom(
                  backgroundColor: secondaryColor.withOpacity(0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              trackHeight: 4,
            ),
            child: Slider(
              value: state.currentPosition.inSeconds.toDouble().clamp(
                0, 
                state.totalDuration.inSeconds.toDouble(),
              ),
              min: 0,
              max: state.totalDuration.inSeconds.toDouble().clamp(1, double.infinity),
              activeColor: color,
              inactiveColor: color.withOpacity(0.2),
              onChanged: (value) {
                _onUserInteraction();
                ref.read(audioPlayerStateProvider.notifier).setPosition(Duration(seconds: value.toInt()));
              },
            ),
          ),
          
          // Time display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(state.currentPosition), 
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryColor),
                ),
                Text(
                  '-${_formatDuration(state.totalDuration - state.currentPosition)}', 
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Speed selector
              _buildSpeedButton(context, ref, state, color),
              // Skip previous
              IconButton(
                onPressed: () {
                  _onUserInteraction();
                  ref.read(audioPlayerStateProvider.notifier).skipPrevious();
                },
                icon: Icon(Icons.skip_previous_rounded, color: textColor, size: 28),
              ),
              // Replay 10s
              IconButton(
                onPressed: () {
                  _onUserInteraction();
                  final newPos = state.currentPosition - const Duration(seconds: 10);
                  ref.read(audioPlayerStateProvider.notifier).setPosition(
                    newPos < Duration.zero ? Duration.zero : newPos,
                  );
                },
                icon: Icon(Icons.replay_10_rounded, color: textColor, size: 28),
              ),
              // Play/pause (large)
              _buildPlayPauseButton(ref, state, color, size: 60, iconSize: 32),
              // Forward 10s
              IconButton(
                onPressed: () {
                  _onUserInteraction();
                  final newPos = state.currentPosition + const Duration(seconds: 10);
                  ref.read(audioPlayerStateProvider.notifier).setPosition(
                    newPos > state.totalDuration ? state.totalDuration : newPos,
                  );
                },
                icon: Icon(Icons.forward_10_rounded, color: textColor, size: 28),
              ),
              // Skip next
              IconButton(
                onPressed: () {
                  _onUserInteraction();
                  ref.read(audioPlayerStateProvider.notifier).skipNext();
                },
                icon: Icon(Icons.skip_next_rounded, color: textColor, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton(WidgetRef ref, AudioPlayerState state, Color color, {double size = 44, double iconSize = 26}) {
    return GestureDetector(
      onTap: () {
        _onUserInteraction();
        if (state.isPlaying) {
          ref.read(audioPlayerStateProvider.notifier).pause();
        } else {
          ref.read(audioPlayerStateProvider.notifier).resume();
        }
      },
      child: Container(
        width: size,
        height: size,
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
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildSpeedButton(BuildContext context, WidgetRef ref, AudioPlayerState state, Color color) {
    return PopupMenuButton<double>(
      onSelected: (speed) {
        _onUserInteraction();
        ref.read(audioPlayerStateProvider.notifier).setSpeed(speed);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, -120),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 0.5, child: Text('0.5x')),
        const PopupMenuItem(value: 0.75, child: Text('0.75x')),
        const PopupMenuItem(value: 1.0, child: Text('1.0x')),
        const PopupMenuItem(value: 1.25, child: Text('1.25x')),
        const PopupMenuItem(value: 1.5, child: Text('1.5x')),
        const PopupMenuItem(value: 2.0, child: Text('2.0x')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString();
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
