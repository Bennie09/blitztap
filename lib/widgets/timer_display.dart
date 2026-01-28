import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class TimerDisplay extends StatelessWidget {
  final Duration timeRemaining;
  final bool isActive;
  final bool isLowTime;

  const TimerDisplay({
    super.key,
    required this.timeRemaining,
    required this.isActive,
    required this.isLowTime,
  });

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    // When time < 10 seconds, show format like "09:7" (no leading zero for seconds)
    if (totalSeconds < 10) {
      return '${minutes.toString().padLeft(2, '0')}:$seconds';
    } else if (totalSeconds >= 60) {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      // Between 10-59 seconds, show MM:SS format
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always keep text white, even when low time (background will be red)
    return Text(
      _formatDuration(timeRemaining),
      style: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}
